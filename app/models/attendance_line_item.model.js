/**
 * @author: Abdul Pathan
 */

const sql = require("./db.js");

let schema = '';
function init(schema_name) {
    this.schema = schema_name;
}

//getAttendanceByStudentIdAndMonth
async function getAttendanceByStudentIdAndMonth(student_id, month) {
    console.log('student_id,month=>', student_id, month);
    let monthlyAttendance = {};
    let query = `SELECT 
    at.*, 
    at.student_id,
    CONCAT(st.firstname, ' ', st.lastname) AS student_name,
    CONCAT(cls.classname, ' ', cls.aliasname) AS class_name, 
    sec.name AS section_name,
    am.class_id, 
    am.section_id,
    am.month,
    atItem.date, 
    atItem.status
FROM 
    ${this.schema}.attendance_line_item AS atItem
    INNER JOIN 
    ${this.schema}.attendance AS at ON at.id = atItem.attendance_id
    INNER JOIN 
        ${this.schema}.student AS st ON st.id = at.student_id
    INNER JOIN 
        ${this.schema}.attendance_master AS am ON am.id = at.attendance_master_id
    INNER JOIN 
        ${this.schema}.class AS cls ON cls.id = am.class_id
    INNER JOIN 
        ${this.schema}.section AS sec ON sec.id = am.section_id`;

    if (student_id !== null && month !== null) {
        console.log("ifHJHH122");
        query += ` WHERE at.student_id = '${student_id}' and am.month = '${month}' ORDER BY atItem.date ASC `;
    }
    console.log('query=>', query)
    const result = await sql.query(query); // Pass params to sql.query
    console.log('result@@=>', result.rows)

    result.rows.forEach(row => {
        const { month, date, status } = row;
        if (!monthlyAttendance[month]) {
            monthlyAttendance[month] = {
                total_present: 0,
                total_absent: 0,
                total_leaves: 0,
                attendance: []
            };
        }

        if (status === 'present') {
            monthlyAttendance[month].total_present++;
        } else if (status === 'absent') {
            monthlyAttendance[month].total_absent++;
        } else {
            monthlyAttendance[month].total_leaves++;
        }

        monthlyAttendance[month].attendance.push({ date, status });
    });

    // Construct the final result object
    const finalResult = {
        id: result.rows[0].id,
        student_id: result.rows[0].student_id,
        attendance_master_id: result.rows[0].attendance_master_id,
        student_name: result.rows[0].student_name,
        class_name: result.rows[0].class_name,
        section_name: result.rows[0].section_name,
        class_id: result.rows[0].class_id,
        section_id: result.rows[0].section_id,
        monthly_attendance: monthlyAttendance
    };
    console.log('finalResult@@=>', finalResult)
    return finalResult;

    return null;
}

//fetch All Records
async function getAllRecords(classId, sectionId, date) {
    console.log('getAllRecords==>', classId, sectionId, date)
    let query = `SELECT
                    ali.id,
                    ali.attendance_id,
                    at.attendance_master_id,
                    st.id AS student_id,
                    CONCAT(st.firstname, ' ', st.lastname) AS student_name,
                    ali.date,
                    ali.status
                FROM ${this.schema}.attendance_line_item ali
                INNER JOIN ${this.schema}.attendance at ON at.id = ali.attendance_id
                INNER JOIN ${this.schema}.student st ON st.id = at.student_id `;


    if (date) {

        query += ` WHERE st.classid = '${classId}' AND st.section_id = '${sectionId}' AND ali.date = '${date}' `;

        const result = await sql.query(query);

        if (result.rows.length > 0)
            return result.rows;
    }
    else if (startDate && endDate) {
        query += ` WHERE st.class_id = '${classId}' AND st.section_id = '${sectionId}' AND ali.date BETWEEN '${startDate}' AND '${endDate}' `;

        const result = await sql.query(query);
        if (result.rows.length > 0)
            return result.rows;
    }
    else {
        return null
    }

};

//getAttendanceByStudentId
async function getAttendanceByStudentIdAndMonth(student_id, month) {


    let monthlyAttendance = {};

    let query = `SELECT 
        at.*, 
        at.student_id,
        CONCAT(st.firstname, ' ', st.lastname) AS student_name,
        CONCAT(cls.classname, ' ', cls.aliasname) AS class_name, 
        sec.name AS section_name,
        am.class_id, 
        am.section_id,
        am.month,
        am.total_lectures,
        atItem.date, 
        atItem.status
    FROM 
        ${this.schema}.attendance_line_item AS atItem
        INNER JOIN 
        ${this.schema}.attendance AS at ON at.id = atItem.attendance_id
        INNER JOIN 
            ${this.schema}.student AS st ON st.id = at.student_id
        INNER JOIN 
            ${this.schema}.attendance_master AS am ON am.id = at.attendance_master_id
        INNER JOIN 
            ${this.schema}.class AS cls ON cls.id = am.class_id
        INNER JOIN 
            ${this.schema}.section AS sec ON sec.id = am.section_id`;

    if (student_id !== null) {
        query += ` WHERE at.student_id = '${student_id}' ORDER BY atItem.date ASC`;
    }
    if (month !== 'null') {
        query += ` and am.month = '${month}' ORDER BY atItem.date ASC`;
    }
    console.log('query=>', query);

    // Execute the query
    const result = await sql.query(query);

    console.log('result.rows@@+>', result.rows);

    if (result.rows.length > 0) {
        result.rows.forEach(row => {
            const { month, date, status } = row;
            if (!monthlyAttendance[month]) {
                monthlyAttendance[month] = {
                    total_present: 0,
                    total_absent: 0,
                    total_leaves: 0,
                    attendance: []
                };
            }

            if (status === 'present') {
                monthlyAttendance[month].total_present++;
            } else if (status === 'absent') {
                monthlyAttendance[month].total_absent++;
            } else {
                monthlyAttendance[month].total_leaves++;
            }

            monthlyAttendance[month].attendance.push({ date, status });
        });

        // Construct the final result object
        const finalResult = {
            id: result.rows[0].id,
            student_id: result.rows[0].student_id,
            attendance_master_id: result.rows[0].attendance_master_id,
            total_lectures: result.rows[0].total_lectures,
            month: result.rows[0].month,
            total_present: result.rows[0].present,
            total_absent: result.rows[0].absent,
            student_name: result.rows[0].student_name,
            class_name: result.rows[0].class_name,
            section_name: result.rows[0].section_name,
            class_id: result.rows[0].class_id,
            section_id: result.rows[0].section_id,
            monthly_attendance: monthlyAttendance
        };

        return finalResult;
    }
    else {
        return null;
    }


}


//fetch Record By Id
async function getRecordById(id) {
    let query = `SELECT * FROM ${this.schema}.attendance_line_item `

    const result = await sql.query(query + ` WHERE id = $1`, [id]);
    if (result.rows.length > 0)
        return result.rows[0];

    return null;
}

//add Record
async function addRecord(req, userid) {
    const result = await sql.query(`INSERT INTO ${this.schema}.attendance_line_item (attendance_id, status, date, createdbyid, lastmodifiedbyid )  VALUES ($1, $2, $3, $4, $5) RETURNING *`,
        [req.attendance_id, req.status, req.date, userid, userid]);

    if (result.rows.length > 0) {
        return { id: result.rows[0].id, ...req };
    }
    return null;
}

//check duplicate Record
async function duplicateRecord(id, req) {
    let query = `SELECT id, attendance_id, status, date FROM ${this.schema}.attendance_line_item `
    console.log('dup query==>', query)
    if (id) {
        query += ` WHERE id = '${id}' AND status = '${req.status}' `;
        const result = await sql.query(query);
        if (result.rows.length > 0) {
            return result.rows[0];
        }
    }

    else {
        query += ` WHERE attendance_id = '${req.attendance_id}' AND date = '${req.date}' `;

        const result = await sql.query(query);
        if (result.rows.length > 0) {
            return result.rows[0];
        }
    }

    return null;
}

//update Record
async function updateRecordById(id, records, userid) {
    records['lastmodifiedbyid'] = userid;
    const query = buildUpdateQuery(id, records, this.schema);
    var colValues = Object.keys(records).map(function (key) {
        return records[key];
    });
    const result = await sql.query(query, colValues);
    if (result.rowCount > 0) {
        return { "id": id, ...records };
    }
    return null;
};

function buildUpdateQuery(id, cols, schema) {

    var query = [`UPDATE ${schema}.attendance_line_item`];
    query.push('SET');
    var set = [];
    Object.keys(cols).forEach(function (key, i) {
        set.push(key + ' = ($' + (i + 1) + ')');
    });
    query.push(set.join(', '));
    query.push('WHERE id = \'' + id + '\'');
    return query.join(' ');
}

module.exports = { getAttendanceByStudentIdAndMonth, getAllRecords, getRecordById, addRecord, duplicateRecord, updateRecordById, init };
