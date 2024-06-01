/**
 * @author: Farhan Khan
 */


const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}
// fetch All Records
async function getAllRecords(id) {
  console.log('id$%%=>',id)
  let query = `
    select ms.*, cls.classname AS classname, s.year AS session
    from ${this.schema}.fee_master ms
    INNER JOIN ${this.schema}.class cls on cls.id = ms.classid
    INNER JOIN ${this.schema}.session s on s.id = ms.sessionid`;

  if (id) {
    query += ` WHERE ms.id = '${id}' OR ms.classid = '${id}'`
  }

  query += ` order by cls.classname`

  const result = await sql.query(query);
  if (result.rows.length > 0)
    return result.rows;

  return null;
}


//fetch All Active Records
async function getAllRecordActiveRecs() {
  let query = `SELECT * FROM ${this.schema}.fee_master fm `;
  query += `INNER JOIN ${this.schema}.class cls ON cls.id = fm.classid`;
  query += ` WHERE fm.status = 'active' `;

  const result = await sql.query(query);
  if (result.rows.length > 0)
    return result.rows;

  return null;
};

// Create Record
async function create(request, userid) {
  let result;

  result = await sql.query(`INSERT INTO ${this.schema}.fee_master (status, total_general_fees, total_obc_fees, total_sc_fees, total_st_fees, sessionid, classid, type, fee_structure, createdbyid, lastmodifiedbyid) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING *`,
    [request[0].status, request[0].total_general_fees, request[0].total_obc_fees, request[0].total_sc_fees, request[0].total_st_fees, request[0].sessionid, request[0].classid, request[0].type, request[0].fee_structure, userid, userid]);
  if (result.rows.length > 0) {

    return { id: result.rows[0].id, ...result };
  }
  return null;
}

// update Record
async function updateRecordById(id, feeHeadRecord, userid) {
  feeHeadRecord['lastmodifiedbyid'] = userid;

  const query = buildUpdateQuery(id, feeHeadRecord);
  var colValues = Object.keys(feeHeadRecord).map(function (key) {
    return feeHeadRecord[key];
  });
  const result = await sql.query(query, colValues);
  if (result.rowCount > 0) {
    return { "id": id, ...feeHeadRecord };
  }
  return null;
};

function buildUpdateQuery(id, cols) {
  var query = [`UPDATE ${this.schema}.fee_master`];
  query.push('SET');
  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + ' = ($' + (i + 1) + ')');
  });
  query.push(set.join(', '));
  query.push('WHERE id = \'' + id + '\'');
  return query.join(' ');
}


async function deleteFeeHead(id) {
  const result = await sql.query(`DELETE FROM ${this.schema}.fee_master WHERE id = $1`, [id]);

  if (result.rowCount > 0)
    return "Success"
  return null;
};

//check duplicate Record
async function duplicateRecord(request) {
  const result = await sql.query(`select * from ${this.schema}.fee_master 
    where classid = $1 AND sessionid = $2
    AND type = $3 AND fee_structure = $4`, [request[0].classid, request[0].sessionid, request[0].type, request[0].fee_structure]);
  if (result.rows.length > 0) {
    return result.rows;
  }

  return null;
}

async function feetypeInstallments(id) {
  console.log('fee master id here -->');
  try {
    const result = await sql.query(
      `select 
      json_build_object(
          'fee_master_id', master.id,
          'type', master.type,
          'total_general_fees', master.total_general_fees,
          'total_obc_fees', master.total_obc_fees,
          'total_sc_fees', master.total_sc_fees,
          'total_st_fees', master.total_st_fees,
          'installmentRecords', (
              select json_agg(
                  json_build_object(
                      'id', mi.id,
                      'month', mi.month,
                      'obc_fee', mi.obc_fee,
                      'general_fee', mi.general_fee,
                      'sc_fee', mi.sc_fee,
                      'st_fee', mi.st_fee,
                      'lineItems', (
                          select json_agg(
                              json_build_object(
                                  'fee_head_master_id', items.fee_head_master_id,
                                  'headname', head.name,
                                  'general_amount', items.general_amount,
                                  'obc_amount', items.obc_amount,
                                  'sc_amount', items.sc_amount,
                                  'st_amount', items.st_amount
                              )
                          )
                          from ${this.schema}.fee_installment_line_items items
                          Inner Join ${this.schema}.fee_head_master head on head.id = items.fee_head_master_id 
                          where items.fee_master_installment_id = mi.id
                      )
                  )
              )
              from ${this.schema}.fee_master_installment mi
              where mi.fee_master_id = master.id
          )
      ) as result
      from ${this.schema}.fee_master master
      where master.id = $1;
      `, [id]
    );

    console.log('result- feetype->', result);

    if (result.rows.length > 0) {
      return result.rows;
    }
    return null;
  } catch (error) {
    console.error('Error executing query', error);
    throw error;
  }
}

module.exports = {
  init, getAllRecords, deleteFeeHead, getAllRecordActiveRecs, feetypeInstallments,

  create, updateRecordById, duplicateRecord
};
