const sql = require("./db.js");

let schema = '';

function init(schema_name) {
  this.schema = schema_name;
}

async function fetchAllRecords() {
  let query = `SELECT * FROM ${this.schema}.student_fee_installments`;
  const result = await sql.query(query);
  return result.rows;
};

async function fetchRecordById(id) {
  let query = `SELECT * FROM ${this.schema}.student_fee_installments`;

  if (id) {
    query += ` WHERE student_addmission_id = $1 Or deposit_id = $1`
  }

  query += ` ORDER BY orderno ASC`;
  const result = await sql.query(query, [id]);
  return result.rows;
};

async function fetchstudentInstallments(admissionid, sessionid) {
  let query = `SELECT json_agg(result) AS result
  FROM (
      SELECT 
        json_build_object(
            'id', stf.id,
            'month', stf.month,
            'status', stf.status,
            'deposited_amount', depo.amount,
            'previous_due', stf.previous_due,
            'due_date', stf.due_date,
            'transport_fee', stf.transport_fee,
            'category', st.category,
            'late_fee', depo.late_fee,
            'payment_date', depo.payment_date,
            'payment_method', depo.payment_method,
            'installment_amount', CASE 
                WHEN st.category = 'General' THEN COALESCE(mi.general_fee, 0)
                WHEN st.category = 'Obc' THEN COALESCE(mi.obc_fee, 0)
                WHEN st.category = 'Sc' THEN COALESCE(mi.sc_fee, 0)
                WHEN st.category = 'St' THEN COALESCE(mi.st_fee, 0)
                ELSE 0
            END,
            'heads', (
                SELECT json_agg(
                    json_build_object(
                        'headname', head.name,
                        'fee_head_master_id', items.fee_head_master_id,
                        'head_amount', CASE 
                            WHEN st.category = 'General' THEN COALESCE(items.general_amount, 0)
                            WHEN st.category = 'Obc' THEN COALESCE(items.obc_amount, 0)
                            WHEN st.category = 'Sc' THEN COALESCE(items.sc_amount, 0)
                            WHEN st.category = 'St' THEN COALESCE(items.st_amount, 0)
                            ELSE 0
                        END
                    )
                ) 
                FROM ${this.schema}.fee_installment_line_items items
                INNER JOIN ${this.schema}.fee_head_master head ON head.id = items.fee_head_master_id
                WHERE items.fee_master_installment_id = stf.fee_master_installment_id
            ),
            'discounts', (
                SELECT json_agg(
                    json_build_object(
                        'id', ds.id,
                        'name', ds.name,
                        'percent', ds.percent,
                        'fee_head_id', ds.fee_head_id
                    )
                ) 
                FROM ${this.schema}.discount_line_items dsitems
                INNER JOIN ${this.schema}.discount ds ON ds.id = dsitems.discountid
                WHERE dsitems.student_addmission_id = stf.student_addmission_id
            )
        ) AS result
      FROM ${this.schema}.student_fee_installments stf
      INNER JOIN ${this.schema}.student_addmission ad ON ad.id = stf.student_addmission_id
      INNER JOIN ${this.schema}.student st ON st.id = ad.studentid
      INNER JOIN ${this.schema}.fee_master_installment mi ON mi.id = stf.fee_master_installment_id
      LEFT JOIN ${this.schema}.fee_deposite depo ON depo.id = stf.deposit_id 
      WHERE stf.student_addmission_id = $1 
        AND stf.session_id = $2
      GROUP BY stf.id, stf.month, stf.status, depo.amount, stf.previous_due, stf.due_date, stf.transport_fee, st.category, depo.late_fee, depo.payment_date, depo.payment_method, mi.general_fee, mi.obc_fee, mi.sc_fee, mi.st_fee
      ORDER BY stf.orderno
  ) AS subquery;
  `;
  const result = await sql.query(query, [admissionid, sessionid]);

  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
};


async function addRecord(newRecord) {
  result = await sql.query(`INSERT INTO ${this.schema}.student_fee_installments (student_addmission_id, fee_master_installment_id, amount, deposit_amount, deposit_id, previous_due, status, due_date, orderno, assign_transport_id, transport_fee, month, session_id) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) RETURNING *`,
    [newRecord?.student_addmission_id, newRecord?.fee_master_installment_id, newRecord?.amount, newRecord?.deposit_amount, newRecord?.deposit_id, newRecord?.previous_due, newRecord?.status, newRecord?.due_date, newRecord?.orderno, newRecord?.assign_transport_id, newRecord?.transport_fee, newRecord?.month, newRecord?.session_id]);
  if (result.rows.length > 0) {

    return { id: result.rows[0].id, ...result.rows[0] };
  }
  return null;
};

async function updateRecordById(id, installmentRecord, userid, tenantcode) {
  installmentRecord["lastmodifiedbyid"] = userid;

  const query = buildUpdateQuery(id, installmentRecord, tenantcode);
  var colValues = Object.keys(installmentRecord).map(function (key) {
    return installmentRecord[key];
  });
  const result = await sql.query(query, colValues);

  if (result.rowCount > 0) {
    return { id: id, ...result.rows[0] };
  }
  return null;
}

function buildUpdateQuery(id, cols, tenantcode) {
  var query = [`UPDATE ${tenantcode}.student_fee_installments`];
  query.push("SET");
  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + " = ($" + (i + 1) + ")");
  });
  query.push(set.join(", "));
  query.push("WHERE id = '" + id + "'");
  return query.join(" ");
}

async function deleteRecord(id) {
  const query = `DELETE FROM ${this.schema}.student_fee_installments WHERE id = $1`;
  const result = await sql.query(query, [id]);

  if (result.rowCount > 0)
    return { message: "Record deleted successfully" }
  return null;
};

async function duplicateRecord(student_addmission_id, fee_master_installment_id) {
  let query = `SELECT id, student_addmission_id, fee_master_installment_id FROM ${this.schema}.student_fee_installments 
      WHERE student_addmission_id = ${student_addmission_id}, AND fee_master_installment_id = ${fee_master_installment_id}`

  const result = await sql.query(query);

  if (result.rows.length > 0) {
    return result.rows[0];
  }
  return null;
}

module.exports = { fetchAllRecords, 
  fetchRecordById, 
  addRecord, 
  updateRecordById, 
  duplicateRecord, 
  deleteRecord, 
  fetchstudentInstallments,
  init };
