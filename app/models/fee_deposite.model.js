const sql = require("./db.js");

let schema = '';
function init(schema_name) {
    this.schema = schema_name;
}

// Insert Fee Deposite into the database
async function createFeeDeposite(newFeeDeposite) {
    try {

        const result = await sql.query(
            `INSERT INTO ${this.schema}.fee_deposite (student_addmission_id, amount, payment_date, payment_method, late_fee, remark, discount, sessionid, pending_amount_id, status) 
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
            [
                newFeeDeposite.student_addmission_id,
                newFeeDeposite.amount,
                newFeeDeposite.payment_date,
                newFeeDeposite.payment_method,
                newFeeDeposite.late_fee,
                newFeeDeposite.remark,
                newFeeDeposite.discount,
                newFeeDeposite.sessionid,
                newFeeDeposite.pending_amount_id,
                newFeeDeposite.status = 'deposit'
            ]
        );

        if (result.rows.length > 0) {
            return { id: result.rows[0].id, newFeeDeposite }
        }
        return null;
    } catch (error) {
        throw error;
    }
}

async function createDueAmount(dueObj, userid) {
    try {

        const result = await sql.query(
            `INSERT INTO ${this.schema}.pending_amount (student_addmission_id, dues, lastmodifieddate, createddate, createdbyid, lastmodifiedbyid, session_id) 
             VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [
                dueObj.student_addmission_id,
                dueObj.dues,
                dueObj.lastmodifieddate,
                dueObj.createddate,
                userid,
                userid,
                dueObj.session_id
            ]
        );

        if (result.rows.length > 0) {
            return { id: result.rows[0].id, ...dueObj };
        }
        return null;
    } catch (error) {
        throw error;
    }
}

// Get all Fee Deposits from the database
async function getAllFeeDeposits() {
    try {
        const result = await sql.query(`SELECT * FROM ${this.schema}.fee_deposite`);
        return result.rows;
    } catch (error) {
        throw error;
    }
}
async function getFeeDepositeById(id, sessionid) {
    try {
        let query = `SELECT depo.*, TO_CHAR(depo.payment_date, 'DD-YYYY-MM') as payment_date 
        FROM ${this.schema}.fee_deposite depo 
        WHERE depo.id = $1 OR depo.pending_amount_id = $1 OR depo.student_addmission_id = $1`;

        let params = [id];

        if (sessionid) {
            query += ` AND depo.sessionid = $2`;
            params.push(sessionid);
        }

        const result = await sql.query(query, params);

        if (result.rowCount > 0) {
            return result.rows;
        }
        return null;
    } catch (error) {
        throw error;
    }
}


// Get Fee Deposite by Student_Addmission ID
async function getFeeDepositeByStudentAddmissionId(id) {
    try {
        const result = await sql.query(`SELECT depo.*, TO_CHAR(depo.payment_date, 'YYYY-MM-DD') as payment_date, cls.classname as classname, s.year as session, itm.general_amount as general_fee,
        itm.obc_amount as obc_fee, itm.sc_amount as sc_fee, itm.st_amount as st_fee, master.month as month,
        master.general_fee as total_general_fee, master.obc_fee as total_obc_fee,
        master.sc_fee as total_sc_fee, master.st_fee as total_st_fee, fm.type as type, itm.id as line_items_id,
        head.name as headname
        FROM  ${this.schema}.fee_deposite depo
        INNER JOIN  ${this.schema}.student_addmission ad on ad.id = depo.student_addmission_id
        INNER JOIN  ${this.schema}.class cls on cls.id = ad.classid
        INNER JOIN  ${this.schema}.session s on s.id = depo.sessionid
		INNER Join  ${this.schema}.student_fee_installments installment on installment.deposit_id = depo.id
        INNER JOIN  ${this.schema}.fee_master_installment master on master.id = installment.fee_master_installment_id
		LEFT JOIN  ${this.schema}.fee_installment_line_items itm on itm.fee_master_installment_id = master.id
        INNER JOIN  ${this.schema}.fee_head_master head on head.id = itm.fee_head_master_id
        INNER JOIN  ${this.schema}.fee_master fm on fm.id = master.fee_master_id
        WHERE depo.student_addmission_id = $1`, [id]);

        if (result.rows.length > 0) {
            return result.rows;
        }
        return null;
    } catch (error) {
        throw error;
    }
}

// Delete a Fee Deposite by ID from the database
async function deleteFeeDeposite(id) {
    try {
        const result = await sql.query(
            `DELETE FROM ${this.schema}.fee_deposite WHERE id = $1 RETURNING *`,
            [id]
        );

        if (result.rows.length === 1) {
            return result.rows[0];
        }
        return null;
    } catch (error) {
        throw error;
    }
}

async function updateRecordById(id, depositRecord, tenantcode) {
    const query = buildUpdateQuery(id, depositRecord, tenantcode);

    var colValues = Object.keys(depositRecord).map(function (key) {
        return depositRecord[key];
    });
    const result = await sql.query(query, colValues);

    if (result.rowCount > 0) {
        return { "id": id, ...depositRecord };
    }
    return null;
};

function buildUpdateQuery(id, cols, tenantcode) {
    var query = [`UPDATE ${tenantcode}.fee_deposite`];
    query.push('SET');
    var set = [];
    Object.keys(cols).forEach(function (key, i) {
        set.push(key + ' = ($' + (i + 1) + ')');
    });
    query.push(set.join(', '));
    query.push('WHERE id = \'' + id + '\'');
    return query.join(' ');
}


async function getPendingAmount(id, sessionid) {
    try {
        let query = `SELECT id, dues FROM ${this.schema}.pending_amount `

        if (id && sessionid) {
            query += `WHERE student_addmission_id = '${id}' AND session_id = '${sessionid}'`
        }



        const result = await sql.query(query);

        if (result.rows.length === 1) {
            return result.rows[0];
        }
    } catch (error) {
        throw error;
    }
}

//check duplicate Record
async function duplicatePendingAmount(id) {
    let query = `SELECT * FROM ${this.schema}.pending_amount WHERE student_addmission_id = '${id}' `;

    const result = await sql.query(query);
    if (result.rows.length > 0) {
        return result.rows;
    }
    return null;
}

async function updatePendingAmountRecordById(id, updatedFeeDeposite, userid) {
    updatedFeeDeposite['lastmodifiedbyid'] = userid;

    const query = buildPedingAmountUpdateQuery(id, this.schema, updatedFeeDeposite);
    var colValues = Object.keys(updatedFeeDeposite).map(function (key) {
        return updatedFeeDeposite[key];
    });
    const result = await sql.query(query, colValues);
    if (result.rowCount > 0) {
        return { "id": id, ...updatedFeeDeposite };
    }
    return null;
};

function buildPedingAmountUpdateQuery(id, tenantcode, cols) {

    var query = [`UPDATE ${tenantcode}.pending_amount`];
    query.push('SET');
    var set = [];
    Object.keys(cols).forEach(function (key, i) {
        set.push(key + ' = ($' + (i + 1) + ')');
    });
    query.push(set.join(', '));
    query.push('WHERE id = \'' + id + '\'');


    return query.join(' ');
}

module.exports = {
    createFeeDeposite,
    getAllFeeDeposits,
    getFeeDepositeById,
    getFeeDepositeByStudentAddmissionId,
    deleteFeeDeposite,
    updateRecordById,
    duplicatePendingAmount,
    updatePendingAmountRecordById,
    createDueAmount,
    getPendingAmount,
    init
};