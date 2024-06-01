/**
 * @author: Pawan Singh Sisodiya
 */


const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}
const feeMasterInstallment = require("../models/fee_master_installment.model.js");
const feeMasterModel = require("../models/fee_master.model.js");
// fetch All Records
async function getAllRecords() {

  let query = `Select * from ${this.schema}.fee_installment_line_items`;

  const result = await sql.query(query);
  if (result.rows.length > 0) return result.rows;

  return null;
}


async function getRecordById(id) {
  let query = `SELECT fi.* FROM ${this.schema}.fee_installment_line_items fi`;
  const result = await sql.query(query + ` WHERE fi.id = $1`, [id]);
  if (result.rows.length > 0) return result.rows[0];
  return null;
}

// fetch Record By fee_master_installment_id
async function getRecordByInstallmentId(installment_id) {
  let query = `SELECT fi.* FROM ${this.schema}.fee_installment_line_items fi`;
  const result = await sql.query(
    `SELECT itm.*, head.name as head_name, cls.classname as classname
  from ${this.schema}.fee_installment_line_items itm
  INNER JOIN ${this.schema}.fee_head_master head on head.id = itm.fee_head_master_id
  Inner JOIN ${this.schema}.fee_master master on master.id = itm.fee_master_id
  INNER JOIN ${this.schema}.class cls on cls.id = master.classid
  where itm.fee_master_installment_id = $1`,
    [installment_id]
  );
  if (result.rows.length > 0) return result.rows;
  return null;
}

// fetch Record By ClassId and Type
async function getRecordByAdmissionIdAndSessionid(admissionid, sessionid) {
  const result = await sql.query(
    `SELECT 
    stf.*, 
    master.type AS fee_type, 
    cls.classname AS classname,
    CASE 
        WHEN st.category = 'General' THEN COALESCE(master.total_general_fees, 0)
        WHEN st.category = 'Obc' THEN COALESCE(master.total_obc_fees, 0)
        WHEN st.category = 'Sc' THEN COALESCE(master.total_sc_fees, 0)
        WHEN st.category = 'St' THEN COALESCE(master.total_st_fees, 0)
        ELSE 0
    END AS total_fees,
    CASE 
        WHEN st.category = 'General' THEN COALESCE(inst.general_fee, 0)
        WHEN st.category = 'Obc' THEN COALESCE(inst.obc_fee, 0)
        WHEN st.category = 'Sc' THEN COALESCE(inst.sc_fee, 0)
        WHEN st.category = 'St' THEN COALESCE(inst.st_fee, 0)
        ELSE 0
    END AS installment_amount,
    head.name AS headname, 
    CASE 
        WHEN st.category = 'General' THEN COALESCE(items.general_amount, 0)
        WHEN st.category = 'Obc' THEN COALESCE(items.obc_amount, 0)
        WHEN st.category = 'Sc' THEN COALESCE(items.sc_amount, 0)
        WHEN st.category = 'St' THEN COALESCE(items.st_amount, 0)
        ELSE 0
    END AS head_amount, 
    pending.dues AS dues,
    head.order_no AS head_order_no,
    head.id AS fee_head_id,
    COALESCE(depo.late_fee, 0) AS late_fee,
    COALESCE(depo.amount, 0) AS deposited_amount,
    COALESCE(d.percent, 0) AS discount_percent,
    -- Calculate discounted amount
   ROUND(COALESCE(stf.amount, 0) * (1 - COALESCE(d.percent, 0) / 100)) AS gross_payable_amount,
   ABS(ROUND(COALESCE(stf.amount, 0) * (1 - COALESCE(d.percent, 0) / 100) - COALESCE(stf.amount, 0))) AS discounted_amount,
   ROUND(COALESCE(stf.amount, 0) - ABS(ROUND(COALESCE(stf.amount, 0) * (1 - COALESCE(d.percent, 0) / 100) - COALESCE(stf.amount, 0)))) + COALESCE(stf.previous_due, 0) AS net_payable_amount
FROM dwps_ajmer.student_fee_installments stf
INNER JOIN dwps_ajmer.student_addmission ad ON ad.id = stf.student_addmission_id
INNER JOIN dwps_ajmer.class cls ON cls.id = ad.classid
INNER JOIN dwps_ajmer.student st ON st.id = ad.studentid
INNER JOIN dwps_ajmer.fee_master master ON master.id = ad.fee_type
LEFT JOIN dwps_ajmer.fee_deposite depo ON depo.id = stf.deposit_id
LEFT JOIN dwps_ajmer.pending_amount pending ON pending.id = depo.pending_amount_id
LEFT JOIN dwps_ajmer.discount_line_items discount ON discount.student_addmission_id = stf.student_addmission_id
LEFT JOIN dwps_ajmer.discount d ON d.id = discount.discountid
INNER JOIN dwps_ajmer.fee_master_installment inst ON inst.id = stf.fee_master_installment_id
INNER JOIN dwps_ajmer.fee_installment_line_items items ON items.fee_master_installment_id = inst.id
INNER JOIN dwps_ajmer.fee_head_master head ON head.id = items.fee_head_master_id
 Where stf.student_addmission_id = $1 and stf.session_id = $2`,
    [admissionid, sessionid]
  );
  //  console.log('return result.rows-->',result);
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}

// async function feetypeInstallments(id) {
//   console.log('fee master id here -->');
//   try {
//     const result = await sql.query(
//       `select 
//       json_build_object(
//           'fee_master_id', master.id,
//           'type', master.type,
//           'total_general_fees', master.total_general_fees,
//           'total_obc_fees', master.total_obc_fees,
//           'total_sc_fees', master.total_sc_fees,
//           'total_st_fees', master.total_st_fees,
//           'installmentRecords', (
//               select json_agg(
//                   json_build_object(
//                       'id', mi.id,
//                       'month', mi.month,
//                       'obc_fee', mi.obc_fee,
//                       'general_fee', mi.general_fee,
//                       'sc_fee', mi.sc_fee,
//                       'st_fee', mi.st_fee,
//                       'lineItems', (
//                           select json_agg(
//                               json_build_object(
//                                   'fee_head_master_id', items.fee_head_master_id,
//                                   'headname', head.name,
//                                   'general_amount', items.general_amount,
//                                   'obc_amount', items.obc_amount,
//                                   'sc_amount', items.sc_amount,
//                                   'st_amount', items.st_amount
//                               )
//                           )
//                           from dwps_ajmer.fee_installment_line_items items
//                           Inner Join dwps_ajmer.fee_head_master head on head.id = items.fee_head_master_id 
//                           where items.fee_master_installment_id = mi.id
//                       )
//                   )
//               )
//               from dwps_ajmer.fee_master_installment mi
//               where mi.fee_master_id = master.id
//           )
//       ) as result
//       from dwps_ajmer.fee_master master
//       where master.id = '$1';
//       `, [id]
//     );

//     console.log('result- feetype->', result);

//     if (result.rows.length > 0) {
//       return result.rows;
//     }
//     return null;
//   } catch (error) {
//     console.error('Error executing query', error);
//     throw error;
//   }
// }
async function getInstallments(classId, type) {
  try {
    console.log(
      "I am here to get fee master installments-->",
      classId,
      "--",
      type
    );
    const query = `SELECT items.*, master.classid, cls.classname as classname, mi.month, head.name as name, mi.status as status
      FROM ${this.schema}.fee_installment_line_items items
      INNER JOIN ${this.schema}.fee_master master on master.id = items.fee_master_id
      INNER JOIN ${this.schema}.class cls on cls.id = master.classid
      INNER JOIN ${this.schema}.fee_master_installment mi on mi.id = items.fee_master_installment_id
      INNER JOIN ${this.schema}.fee_head_master head on head.id = items.fee_head_master_id
      WHERE master.classid = $1 AND master.type = $2`;

    const result = await sql.query(query, [classId, type]);

    console.log("return getInstallments-->", result.rows);

    return result.rows;
  } catch (error) {

    throw new Error("Failed to get installments");
  }
}

//Create Record
async function create(request, installmentResult, userid, tenantcode) {

  let results = [];

  let studentFee = {
    total_general_fees: 0,
    total_obc_fees: 0,
    total_sc_fees: 0,
    total_st_fees: 0,
  };

  for (let res of request) {
    for (let data of res.fee_head_master_id) {
      const fee_head_id = data?.head_master_id;
      const general_fee = data?.general_fee;
      const obc_fee = data?.obc_fee;
      const sc_fee = data?.sc_fee;
      const st_fee = data?.st_fee;

      let tempObj = installmentResult?.filter(
        (data) => data?.month === res.month
      );
      let fee_master_Installment_id = tempObj[0]?.id;
      let fee_master_id = tempObj[0]?.fee_master_id;

      const result = await sql.query(
        `INSERT INTO ${this.schema}.fee_installment_line_items (fee_head_master_id, fee_master_id,general_amount, obc_amount, sc_amount, st_amount,fee_master_installment_id, createdbyid, lastmodifiedbyid) VALUES ($1, $2, $3, $4, $5, $6, $7, $8,$9) RETURNING *`,
        [
          fee_head_id,
          fee_master_id,
          general_fee,
          obc_fee,
          sc_fee,
          st_fee,
          fee_master_Installment_id,
          userid,
          userid,
        ]
      );
      results.push(result.rows[0]);
    }
  }

  for (let res of installmentResult) {
    console.log("Inside the installmentResult loop->");
    let tempInstall = results?.filter(
      (data) => data?.fee_master_installment_id === res.id
    );
    const totalcount = {
      general_fee: 0,
      obc_fee: 0,
      sc_fee: 0,
      st_fee: 0,
    };
    for (let data of tempInstall) {
      studentFee.total_general_fees =
        parseInt(studentFee.total_general_fees) + parseInt(data.general_amount);
      totalcount.general_fee =
        parseInt(totalcount.general_fee) + parseInt(data.general_amount);

      studentFee.total_obc_fees =
        parseInt(studentFee.total_obc_fees) + parseInt(data.obc_amount);
      totalcount.obc_fee =
        parseInt(totalcount.obc_fee) + parseInt(data.obc_amount);

      studentFee.total_sc_fees =
        parseInt(studentFee.total_sc_fees) + parseInt(data.sc_amount);
      totalcount.sc_fee =
        parseInt(totalcount.sc_fee) + parseInt(data.sc_amount);

      studentFee.total_st_fees =
        parseInt(studentFee.total_st_fees) + parseInt(data.st_amount);
      totalcount.st_fee =
        parseInt(totalcount.st_fee) + parseInt(data.st_amount);
    }


    // ------------ UPDATE FEE MASTER INSTALLMENT ---------------
    feeMasterInstallment.init(tenantcode);
    const updateFeeMasterInstallment =
      await feeMasterInstallment.updateRecordById(res.id, totalcount, userid);
    console.log("updateFeeMasterInstallment", updateFeeMasterInstallment);

    // -------------- UPDATE FEE MASTER TOTAL FEE -------------------
    feeMasterModel.init(tenantcode);
    const updateFeeMasterTotalFees = await feeMasterModel.updateRecordById(
      res.fee_master_id,
      studentFee,
      userid
    );
    console.log("updateFeeMasterTotalFees", updateFeeMasterTotalFees);
  }
  console.log("total studentFee-->", studentFee);

  return null;
}

// update Record
async function updateRecordById(id, feeHeadRecord, userid) {
  feeHeadRecord["lastmodifiedbyid"] = userid;

  const query = buildUpdateQuery(id, feeHeadRecord);
  var colValues = Object.keys(feeHeadRecord).map(function (key) {
    return feeHeadRecord[key];
  });
  const result = await sql.query(query, colValues);
  if (result.rowCount > 0) {
    return { id: id, ...feeHeadRecord };
  }
  return null;
}

function buildUpdateQuery(id, cols) {
  var query = [`UPDATE ${this.schema}.fee_installment_line_items`];
  query.push("SET");
  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + " = ($" + (i + 1) + ")");
  });
  query.push(set.join(", "));
  query.push("WHERE id = '" + id + "'");
  return query.join(" ");
}

async function deleteFeeHead(id) {
  const result = await sql.query(
    `DELETE FROM ${this.schema}.fee_installment_line_items WHERE id = $1`,
    [id]
  );

  if (result.rowCount > 0) return "Success";
  return null;
}

//check duplicate Record
async function duplicateRecord(id, request) {
  let query = `SELECT id FROM ${this.schema}.fee_installment_line_items `;

  // if (request.name) {
  //   query += ` WHERE name = '${request.name}' `;

  if (id) {
    query += ` AND id != '${id}'  `;
  }

  const result = await sql.query(query);
  if (result.rows.length > 0) {
    return result.rows;
  }
  // }

  return null;
}

async function updateRecordByIdFee(id, newFeeLineItem, userid) {
  try {
    const result = await sql.query(
      `UPDATE ${this.schema}.fee_installment_line_items SET general_amount  = $1,  obc_amount  = $2, sc_amount  = $3,  st_amount  = $4 WHERE id = $5 RETURNING *`,
      [
        newFeeLineItem.general_amount,
        newFeeLineItem.sessionid,
        newFeeLineItem.sc_amount,
        newFeeLineItem.st_amount,
        userid,
        id,
      ]
    );

    if (result.rows.length > 0) {
      return { id, ...newFeeLineItem };
    }

    return null;
  } catch (error) {
    throw error;
  }
}

module.exports = {
  init,
  getAllRecords,
  deleteFeeHead,
  getRecordByInstallmentId,
  getRecordByAdmissionIdAndSessionid,
  create,
  updateRecordById,
  duplicateRecord,
  updateRecordByIdFee,
  getInstallments,
  getRecordById,
};
