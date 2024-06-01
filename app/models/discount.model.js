const sql = require("./db.js");

let schema = '';
function init(schema_name) {
    this.schema = schema_name;
}

async function fetchAllRecords() {
    let query = `select ds.*, s.year as session, head.name as headname
    from ${this.schema}.discount ds
    Inner Join ${this.schema}.session s on s.id = ds.sessionid
    Inner Join ${this.schema}.fee_head_master head on head.id = ds.fee_head_id`;
    const result = await sql.query(query);
    return result.rows;
};

async function fetchRecordById(id) {
    let query = `select ds.* from ${this.schema}.discount ds
    WHERE ds.id = $1`;
    const result = await sql.query(query, [id]);
    if (result.rows.length > 0)
        return result.rows[0];
    return null;
};

async function addRecord(newDiscount, userid) {
    const result = await sql.query(`INSERT INTO ${this.schema}.discount (name, percent, sessionid, fee_head_id, status, createdbyid, lastmodifiedbyid) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
        [newDiscount.name, newDiscount.percent, newDiscount.sessionid, newDiscount.fee_head_id, newDiscount.status, userid, userid]);
    if (result.rows.length > 0) {
        return { id: result.rows[0].id, ...newDiscount };
    }
    return null;
};

async function updateRecordById(id, newFeeLineItem, userid) {
    newFeeLineItem['lastmodifiedbyid'] = userid;

    const query = buildUpdateQuery(id, newFeeLineItem, this.schema);
    var colValues = Object.keys(newFeeLineItem).map(function (key) {
        return newFeeLineItem[key];
    });
    const result = await sql.query(query, colValues);
    if (result.rowCount > 0) {
        return { "id": id, ...newFeeLineItem };
    }
    return null;
};

function buildUpdateQuery(id, cols, schema) {
    var query = [`UPDATE ${schema}.discount`];
    query.push('SET');
    var set = [];
    Object.keys(cols).forEach(function (key, i) {
        set.push(key + ' = ($' + (i + 1) + ')');
    });
    query.push(set.join(', '));
    query.push('WHERE id = \'' + id + '\'');
    return query.join(' ');
}


async function deleteRecord(id) {
    try {
        const result = await sql.query(`DELETE FROM ${this.schema}.discount WHERE id = $1`, [id]);
        if (result.rowCount > 0)
            return "Success";
    } catch (error) {
        return null;
    }
};

async function duplicateRecord(id, request) {
    try {
        let query = `SELECT id, name, percent FROM ${this.schema}.discount WHERE name = $1 AND sessionid = $2`;
        const queryParams = [request.name, request.sessionid];

        if (id) {
            query += ` AND percent = $3 AND id != $4 `;
            queryParams.push(request.percent, id);
        }

        const result = await sql.query(query, queryParams);
        if (result.rows.length > 0) {
            return result.rows[0];
        }
        return null;
    } catch (error) {
        console.error('Error in duplicateRecord:', error);
        throw error;
    }
}

module.exports = { fetchAllRecords, fetchRecordById, addRecord, updateRecordById, deleteRecord, duplicateRecord, init };
