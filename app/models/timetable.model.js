/**
 * @author : Pooja Vaishnav
 */

const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}

//fetchAllRecordsByClassId
async function fetchAllRecordsByTeacher(type, contact_id, currentYearId) {
  let query = `SELECT 
  tim.*,
  cls.id AS classid,  
  cls.status, 
  sec.id AS section_id,
  sec.name AS section_name,
  con.id AS contact_id,
  CONCAT(con.firstname, ' ', con.lastname) AS contact_name,
  sub.name AS subject_name,
  concat(cls.classname, ' (', sec.name, ')') AS classname
FROM ${this.schema}.timetable tim
INNER JOIN ${this.schema}.section sec ON sec.id = tim.section_id 
INNER JOIN ${this.schema}.contact con ON con.id = tim.contact_id 
INNER JOIN ${this.schema}.subject sub ON sub.id = tim.subject_id 
INNER JOIN ${this.schema}.class cls ON cls.id = sec.class_id  
INNER JOIN ${this.schema}.time_slot timSlot ON timSlot.id = tim.time_slot_id
WHERE  tim.type = '${type}' AND tim.contact_id = '${contact_id}' AND tim.session_id = '${currentYearId}'
`;


  const result = await sql.query(query);

  if (result.rows.length > 0) {

    return result.rows;
  }
  return null;
}
//fetchAllRecordsByClassId
async function fetchAllRecordsByClassId(
  classId,
  sectionid,
  currentYearId,
  type
) {

  let query = `SELECT 
  tim.*,
  sec.id AS section_id,
  con.id AS contact_id,
  CONCAT(con.firstname, ' ', con.lastname) AS contact_name,
  concat(' (', sub.name, ')') AS subject_name
FROM ${this.schema}.timetable tim
INNER JOIN ${this.schema}.section sec ON sec.id = tim.section_id 
INNER JOIN ${this.schema}.contact con ON con.id = tim.contact_id 
INNER JOIN ${this.schema}.subject sub ON sub.id = tim.subject_id 
INNER JOIN ${this.schema}.time_slot timSlot ON timSlot.id = tim.time_slot_id
WHERE tim.section_id = '${sectionid}' and tim.session_id = '${currentYearId}' and tim.type ='${type}'`;

  const result = await sql.query(query);

  if (result.rows.length > 0) {

    return result.rows;
  }
  return null;
}
async function fetchRecords(classId, sectionId) {

  let query = `SELECT 
                tim.*,
                cls.id AS classid, 
                cls.id AS class_id,  
                cls.classname,
                sec.name AS section_name,
                CONCAT(con.firstname, ' ', con.lastname) AS teacher_name,
                concat(' (', sub.name, ')') AS subject_name,
                sub.name AS subject,
                timSlot.start_time as start_time,
                timSlot.end_time as end_time,
                timSlot.id as timeSlotId,
                timSlot.id as time_slot_id
              FROM ${this.schema}.timetable tim 
              INNER JOIN ${this.schema}.section sec ON sec.id = tim.section_id 
              INNER JOIN ${this.schema}.contact con ON con.id = tim.contact_id 
              INNER JOIN ${this.schema}.subject sub ON sub.id = tim.subject_id 
              INNER JOIN ${this.schema}.class cls ON cls.id = sec.class_id 
              INNER JOIN ${this.schema}.time_slot timSlot ON timSlot.id = tim.time_slot_id
              WHERE true `;

  if (classId) {
    query += ` AND tim.class_id = '${classId}' `;
  }

  if (sectionId) {
    query += ` AND tim.section_id = '${sectionId}' `;
  }

  query += ` ORDER BY teacher_name `;

  const result = await sql.query(query);

  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}

function removeUnwantedFields(records, fieldsToRemove) {
  return records.map((record) => {
    const filteredRecord = { ...record };
    fieldsToRemove.forEach((field) => delete filteredRecord[field]);

    return filteredRecord;
  });
}

async function insertRecords(records, schema) {

  records = removeUnwantedFields(records, ["id"]);


  const placeholders = records
    .map((record, index) => {
      const keys = Object.keys(record);
      const placeholderString = keys
        .map((key, i) => `$${index * keys.length + i + 1}`)
        .join(", ");
      return `(${placeholderString})`;
    })
    .join(", ");

  // Get the column names from the first record
  const columns = Object.keys(records[0]).join(", ");

  const query = `
      INSERT INTO ${schema}.timetable (${columns})
      VALUES ${placeholders}
      RETURNING id
    `;

  // Flatten the records array to pass values directly to query function
  const values = records.reduce(
    (acc, record) => [...acc, ...Object.values(record)],
    []
  );
  // Execute the query
  const result = await sql.query(query, values);
  return result.rows.map((row) => {

    return row.id;
  });
}

async function updateRecords(records, schema) {

  let ids = [];
  for (const record of records) {
    const { id, ...updateValues } = record; // Exclude id from update values
    const updateColumns = Object.keys(updateValues)
      .map((key, index) => `${key} = $${index + 1}`)
      .join(", ");



    const query = `
                UPDATE ${schema}.timetable 
                SET ${updateColumns}
                WHERE id = $${Object.keys(updateValues).length + 1}
            `;


    const values = [...Object.values(updateValues), id];

    const result = await sql.query(query, values);
    if (result.rowCount > 0) {
      ids.push(id);
    }
  }

  return ids;
}

async function upsertRecords(records) {

  records = records.map(
    ({
      id,
      class_id,
      contact_id,
      subject_id,
      time_slot_id,
      section_id,
      day,
      session_id,
    }) => ({
      id,
      class_id,
      contact_id,
      subject_id,
      time_slot_id,
      section_id,
      day,
      session_id,
    })
  );

  const { insertRecordList, updateRecordList } = separateRecords(records);
  try {
    let insertedIds = [];
    let updatedIds = [];
    await sql.query("BEGIN");
    if (insertRecordList && insertRecordList.length > 0) {
      insertedIds = await insertRecords(insertRecordList, this.schema);
    }

    if (updateRecordList && updateRecordList.length > 0) {
      updatedIds = await updateRecords(updateRecordList, this.schema);
    }
    await sql.query("COMMIT");

    return { success: true, insertedIds, updatedIds };
  } catch (error) {
    await sql.query("ROLLBACK");

    return { success: false, error: error.message };
  } finally {
    // Release resources if needed
  }
  return false;
}

function separateRecords(records) {
  const insertRecordList = records.filter((record) => record.id === null);
  const updateRecordList = records.filter((record) => record.id !== null);

  return { insertRecordList, updateRecordList };
}

async function fetchAllRecordsByIds(timeslotid, contact_id, day, subjectid) {
  let query = `SELECT tim.* FROM ${this.schema}.timetable tim 
  WHERE tim.time_slot_id = '${timeslotid}' and tim.contact_id = '${contact_id}' and day = '${day}'
  and tim.subject_id = '${subjectid}'`;

  const result = await sql.query(query);

  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}
//fetchAllRecordsByClassId
async function fetchAllData() {
  let query = `SELECT 
  tim.*,
  cls.classname,
  cls.id AS classid,  
  sec.id AS section_id,
  sec.name AS section_name,
  con.id AS contact_id,
  CONCAT(con.firstname, ' ', con.lastname) AS contact_name,
  sub.name AS subject_name,
  concat(cls.classname, ' (', sec.name, ')') AS classname,
  timSlot.start_time as start_time,
  timSlot.end_time as end_time,
  timSlot.id as timeSlotId
FROM ${this.schema}.timetable tim
INNER JOIN ${this.schema}.section sec ON sec.id = tim.section_id 
INNER JOIN ${this.schema}.contact con ON con.id = tim.contact_id 
INNER JOIN ${this.schema}.subject sub ON sub.id = tim.subject_id 
INNER JOIN ${this.schema}.class cls ON cls.id = sec.class_id  
INNER JOIN ${this.schema}.time_slot timSlot ON timSlot.id = tim.time_slot_id`;


  const result = await sql.query(query);

  if (result.rows.length > 0) {

    return result.rows;
  }
  return null;
}

async function fetchAllRecordsWithTeacher(contact_id, session_id) {
  let query = `SELECT 
  tim.*,
  cls.id AS classid,  
  cls.status, 
  sec.id AS section_id,
  concat(cls.classname, ' (', sec.name, ')') AS classname,
  con.id AS contact_id,
  CONCAT(con.firstname, ' ', con.lastname) AS contact_name,
  concat('(',sub.name,')') AS subject_name,
  timSlot.id as time_slot_id,
  CONCAT(timSlot.start_time, ' ', timSlot.end_time) AS period_time
FROM ${this.schema}.timetable tim
INNER JOIN ${this.schema}.section sec ON sec.id = tim.section_id 
INNER JOIN ${this.schema}.contact con ON con.id = tim.contact_id 
INNER JOIN ${this.schema}.subject sub ON sub.id = tim.subject_id 
INNER JOIN ${this.schema}.class cls ON cls.id = sec.class_id  
INNER JOIN ${this.schema}.time_slot timSlot ON timSlot.id = tim.time_slot_id
WHERE tim.contact_id = '${contact_id}' AND tim.session_id = '${session_id}'`;

  const result = await sql.query(query);

  if (result.rows.length > 0) {

    return result.rows;
  }
  return null;
}
async function fetchAllRecords(classtype) {
  let query = `SELECT tim.* FROM ${this.schema}.timetable tim`;

  const result = await sql.query(query + ` WHERE tim.type = $1`, [classtype]);

  if (result.rows.length > 0) {
    ;
    return result.rows;
  }
  return null;
}
async function fetchRecordById(id, contact_id, section_id, subjectId) {

  let query = `SELECT tim.* FROM ${this.schema}.timetable tim WHERE tim.id = $1;`;
  const result = await sql.query(query, [id]);
  if (result.rows.length > 0) {

    if (
      result.rows[0].contact_id != contact_id ||
      result.rows[0].section_id != section_id ||
      result.rows[0].subject_id != subjectId
    ) {

      return result.rows[0];
    }
  }
  return null;
}
//fetchRecord By Class Id and Section Id Based on Class Wise
async function fetchRecordByClassWise(classId, sectionId) {
  let query = `
          SELECT 
                        tim.*,
                        CONCAT(tim.start_time, ' to ', tim.end_time) AS period_time,
                        cls.id as class_id,
                        cls.classname,
                        sec.id as section_id,
                        sec.name as section_name,
                        con.id as contact_id,
                        CONCAT(con.firstname, ' ', con.lastname) AS contact_name,
                        sub.id as subject_id,
                        sub.name as subject_name,
                        timSlot.type
                        FROM ${this.schema}.timetable tim
                        INNER JOIN ${this.schema}.class cls ON cls.id = tim.class_id 
                        INNER JOIN ${this.schema}.section sec ON sec.id = tim.section_id 
                        INNER JOIN ${this.schema}.contact con ON con.id = tim.contact_id 
                        INNER JOIN ${this.schema}.subject sub ON sub.id = tim.subject_id 
                        INNER JOIN ${this.schema}.time_slot timSlot ON timSlot.id = tim.time_slot_class_id`;
  ;
  const result = await sql.query(
    query + ` WHERE tim.class_id = $1 OR tim.section_id = $2`,
    [classId, sectionId]
  );


  const groupedData = {};
  result.rows.forEach((item) => {
    const day = item.day;
    if (!groupedData[day]) {
      groupedData[day] = [];
    }
    groupedData[day].push(item);
  });

  const groupedArray = Object.values(groupedData);

  if (result.rows.length > 0) return groupedArray;
  // return result.rows;
  return null;
}

//fetchRecord By Contact Id Based on Teacher Wise
async function fetchRecordByTeacherWise(contact_id) {
  let query = `
          SELECT 
                        tim.*,
                        CONCAT(tim.start_time, ' to ', tim.end_time) AS period_time,
                        cls.id as class_id,
                        cls.classname,
                        sec.id as section_id,
                        sec.name as section_name,
                        con.id as contact_id,
                        CONCAT(con.firstname, ' ', con.lastname) AS contact_name,
                        sub.id as subject_id,
                        sub.name as subject_name,
                        timSlot.type
                        FROM ${this.schema}.timetable tim
                        INNER JOIN ${this.schema}.class cls ON cls.id = tim.class_id 
                        INNER JOIN ${this.schema}.section sec ON sec.id = tim.section_id 
                        INNER JOIN ${this.schema}.contact con ON con.id = tim.contact_id 
                        INNER JOIN ${this.schema}.subject sub ON sub.id = tim.subject_id 
                        INNER JOIN ${this.schema}.time_slot timSlot ON timSlot.id = tim.time_slot_class_id`;

  const result = await sql.query(query + ` WHERE tim.contact_id = $1`, [
    contact_id,
  ]);

  if (result.rows.length > 0) return result.rows;
  return null;
}
async function addRecords(newTimetables, userid) {

  const insertedRecords = [];
  for (const key in newTimetables) {
    const timetable = newTimetables[key];

    for (let i = 1; i <= 6; i++) {
      const objKey = `obj${i}`;

      const newTimetable = timetable[objKey];

      if (
        newTimetable[`teacher${i}`] &&
        newTimetable[`subject${i}`] &&
        newTimetable.section_id
      ) {

        const result = await sql.query(
          `
              INSERT INTO ${this.schema}.timetable (section_id, contact_id, subject_id, time_slot_id, day, session_id, status, type, createdbyid, lastmodifiedbyid)
              VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
              RETURNING *
          `,
          [
            newTimetable.section_id,
            newTimetable[`teacher${i}`],
            newTimetable[`subject${i}`],
            newTimetable.value,
            newTimetable.day,
            newTimetable.sessionid,
            newTimetable.status,
            newTimetable.type,
            userid,
            userid,
          ]
        );

        if (result.rows.length > 0) {

          insertedRecords.push({ id: result.rows[0].id, ...newTimetable });
        }
      }

    }
  }
  return insertedRecords;
}


async function addRecordOnEdit(newTimetable, userid) {


  const result = await sql.query(
    `INSERT INTO ${this.schema}.timetable (day,section_id,time_slot_id,contact_id, subject_id,session_id,type,status,createdbyid, lastmodifiedbyid ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9,$10) RETURNING *`,
    [
      newTimetable.day,
      newTimetable.section_id,
      newTimetable.time_slot_id,
      newTimetable.contact_id,
      newTimetable.subject_id,
      newTimetable.session_id,
      newTimetable.type,
      newTimetable.status,
      userid,
      userid,
    ]
  );

  if (result.rows.length > 0) {
    return { id: result.rows[0].id, ...newTimetable };
  }
}

async function updateRecordById(id, newTimetable, userid) {

  newTimetable["lastmodifiedbyid"] = userid;
  const query = buildUpdateQuery(newTimetable.id, newTimetable, this.schema);

  const colValues = Object.keys(newTimetable).map(function (key) {

    return newTimetable[key];
  });

  const result = await sql.query(query, colValues);

  if (result.rowCount > 0) {
    return { id: id, ...newTimetable };
  }
  return null;
}

function buildUpdateQuery(id, cols, schema) {

  var query = [`UPDATE ${schema}.timetable`];

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
  try {

    const result = await sql.query(
      `DELETE FROM ${this.schema}.timetable WHERE id = $1`,
      [id]
    );

    if (result.rowCount > 0) {
      return "Success";
    } else {
      return null;
    }
  } catch (error) {
    console.log("delete error=>", error);
    return null;
  }
  // return null;
}

// Added By Pooja || check duplicate Record
async function duplicateRecords(requests) {
  const duplicates = [];

  for (const key in requests) {
    const request = requests[key];

    let query = `SELECT id, class_id, contact_id, subject_id, time_slot_id, session_id,type FROM ${this.schema}.timetable `;


    if (request.value) {

      query += ` WHERE id != '${request.value}' AND section_id = '${request.section_id}' AND contact_id = '${request.contact_id}' AND subject_id = '${request.subject_id}' AND time_slot_id = '${request.time_slot_class_id}' AND session_id = '${request.session_id}' 
      AND type = '${request.type}'`;

    } else {

      query += ` WHERE section_id = '${request.section_id}' AND contact_id = '${request.contact_id}' AND subject_id = '${request.subject_id}' AND time_slot_id = '${request.time_slot_class_id}' AND session_id = '${request.session_id}' 
      AND type = '${request.type}'`;
    }

    const result = await sql.query(query);


    if (result.rows.length > 0) {
      duplicates.push(result.rows[0]);
    }
  }

  return duplicates.length > 0 ? duplicates : null;
}

async function duplicateRecord(id, request) {

  let query = `SELECT id, section_id,contact_id, subject_id, time_slot_id,session_id FROM ${this.schema}.timetable `;

  if (id) {

    query += ` WHERE id = '${id}' AND section_id = '${request.section_id}' AND contact_id = '${request.contact_id}' AND subject_id = '${request.subject_id}' AND time_slot_id = '${request.time_slot_id}' 
    AND session_id = '${request.session_id}'`;

  } else {

    query += ` WHERE section_id = '${request.section_id}' AND contact_id = '${request.contact_id}' AND subject_id = '${request.subject_id}' AND time_slot_id = '${request.time_slot_id}'
     AND session_id = '${request.session_id}' `;
  }
  const result = await sql.query(query);

  if (result.rows.length > 0) {
    return result.rows[0];
  }
  return null;
}

module.exports = {
  fetchAllData,
  fetchRecords,
  addRecordOnEdit,
  fetchAllRecordsWithTeacher,
  fetchAllRecordsByTeacher,
  fetchAllRecordsByIds,
  fetchAllRecordsByClassId,
  fetchAllRecords,
  fetchRecordById,
  addRecords,
  updateRecordById,
  deleteRecord,
  duplicateRecord,
  duplicateRecords,
  init,
  fetchRecordByClassWise,
  fetchRecordByTeacherWise,
  upsertRecords,
};