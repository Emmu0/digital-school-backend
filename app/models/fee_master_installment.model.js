/**
 * @author: Pawan Singh Sisodiya
 */

// const { request } = require("express");
const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}
const feeMasterModel = require("../models/fee_master.model.js");
const { json } = require("express");

// fetch All Records
async function getAllRecords() {
  // let query = `SELECT  * FROM fee_master fm`
  let query = `select fee_master_installment.id AS id, fee_master_installment.status AS status,
    fee_master_installment.general_fee AS general_fee, fee_master_installment.obc_fee AS obc_fee, 
    fee_master_installment.sc_fee AS sc_fee, fee_master_installment.st_fee AS st_fee,
    fee_master_installment.month AS month, 
    session.year AS session, fee_master_installment.fee_master_id AS fee_master_id,
    fee_master.classid AS classid, class.classname as classname, fee_master.totalfees AS totalfees,
    fee_master.fee_structure AS fee_structure, fee_master.type AS type
    from ${this.schema}.fee_master_installment 
    LEFT JOIN ${this.schema}.fee_master ON fee_master.id = fee_master_installment.fee_master_id
    LEFT JOIN ${this.schema}.session ON session.id = fee_master_installment.sessionid
    LEFT JOIN ${this.schema}.class ON class.id = fee_master.classid`;
  const result = await sql.query(query);

  if (result.rows.length > 0)
    return result.rows;

  return null;
}



// fetch Record By Id
async function getRecordById(id) {
  const result = await sql.query(`SELECT * FROM ${this.schema}.fee_master_installment WHERE fee_master_id = $1`, [id]);

  if (result.rows.length > 0)
    return result.rows;

  return null;
}


// Create Record
//async function create(request, totalcount, userid) {
async function create(request, feeMasterId, userid) {
  let results = [];
  const currentDate = new Date();

  for (let i = 0; i < request.length; i++) {
    const result = await sql.query(`INSERT INTO ${this.schema}.fee_master_installment (fee_master_id, status, sessionid, month, createddate, createdbyid, lastmodifiedbyid)  VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
      [feeMasterId, request[i].status, request[i].sessionid, request[i].month, currentDate, userid, userid]);
    results.push(result.rows[0]);
  }

  if (results.length > 0) {
    return results;
  }
  return null;
}

// update Record
async function updateRecordById(id, newFeeLineItem, userid) {
  newFeeLineItem['lastmodifiedbyid'] = userid;

  const query = buildUpdateQuery(id, newFeeLineItem);
  var colValues = Object.keys(newFeeLineItem).map(function (key) {
    return newFeeLineItem[key];
  });
  const result = await sql.query(query, colValues);
  if (result.rowCount > 0) {
    return { "id": id, ...newFeeLineItem };
  }
  return null;
};

function buildUpdateQuery(id, cols) {
  var query = [`UPDATE ${this.schema}.fee_master_installment`];
  query.push('SET');
  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + ' = ($' + (i + 1) + ')');
  });
  query.push(set.join(', '));
  query.push('WHERE id = \'' + id + '\'');
  return query.join(' ');
}


async function getRecordDuringUpdate(id) {
  let query = `SELECT fm.id, fm.* FROM ${this.schema}.fee_master_installment fm`
  const result = await sql.query(query + ` WHERE fm.id = $1`, [id]);


  if (result.rows.length > 0)
    return result.rows;

  return null;
}

async function deleteFeeHead(id) {
  const result = await sql.query(`DELETE FROM ${this.schema}.fee_master_installment WHERE id = $1`, [id]);

  if (result.rowCount > 0)
    return "Success"
  return null;
};


module.exports = { init, getAllRecords, deleteFeeHead, getRecordById, create, updateRecordById, getRecordDuringUpdate };