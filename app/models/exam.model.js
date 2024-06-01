/**
 * @author: Pawan Singh Sisodiya
 */

const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}

// ** ** ** ** ** ** ** Operations For Exam Title ** ** ** ** ** ** **

async function createExamTitle(newTitle) {
  try {
    const result = await sql.query(
      `INSERT INTO ${this.schema}.exam_title (name, status, sessionid)  VALUES ($1, $2, $3) RETURNING *`,
      [newTitle.name, newTitle.status, newTitle.sessionid]
    );

    if (result.rows.length > 0) {
      return { id: result.rows[0].id, ...newTitle };
    }
    return null;
  } catch (error) {
    throw error;
  }
}


async function getExamTitles() {
  console.log('Heelo');
  try {
    console.log('yesgo')
    //query += "INNER JOIN public.user mu ON mu.Id = stu.lastmodifiedbyid";
    //Add by Aamir khan 06-05-204
    console.log('sql.query==>',sql.query);
    const result = await sql.query(`SELECT exam.*, sess.year FROM ${this.schema}.exam_title exam 
    INNER JOIN  ${this.schema}.session sess ON sess.Id = exam.sessionid`);

    console.log('sql.query==>1',sql.query);

    console.log('@#result.row==>', result.row);
    return result.rows;
  } catch (error) {
    console.log('DataNo=>',error);
    console.log('NewErrorPrint', error);
    throw error;
  }
}

async function updateExamTitleById(id, newTitle) {
  try {
    const existingTitle = await sql.query(`SELECT * FROM ${this.schema}.exam_title WHERE id = $1`, [id]);

    if (existingTitle.rows.length === 0) {
      return null;
    }
    const result = await sql.query(
      `UPDATE ${this.schema}.exam_title SET name = $1, status = $2 WHERE id = $3 RETURNING *`,
      [newTitle.name, newTitle.status, id]
    );

    if (result.rows.length > 0) {
      return { id, ...newTitle };
    }

    return null;
  } catch (error) {
    throw error;
  }
}

async function getExamTitleById(id) {
  try {
    const result = await sql.query(` SELECT ext.*, ext.name, ext.status, ext.sessionid,
        (SELECT s.year FROM ${this.schema}.session s WHERE s.id = ext.sessionid) AS year
      FROM ${this.schema}.exam_title ext WHERE id = $1`, [id]);

    if (result.rows.length > 0) {
      return result.rows[0];
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function deleteExamTitle(id) {
  try {
    const existingReference = await sql.query(
      `SELECT * FROM ${this.schema}.exam_schedule WHERE exam_title_id = $1`, [id]);

    if (existingReference.rows.length > 0) {
      throw new Error("Record has reference in another table. Deletion not allowed.");
    }

    const existingTitle = await sql.query(`SELECT * FROM ${this.schema}.exam_title WHERE id = $1`, [id]);

    if (existingTitle.rows.length === 0) {
      return null;
    }

    const result = await sql.query(`DELETE FROM ${this.schema}.exam_title WHERE id = $1`, [id]);



    if (result.rowCount > 0) {
      return { message: "Exam title deleted successfully!!!" };
    }
    return null;
  } catch (error) {
    throw error;
  }
}


//----------------------------------------------------------------------------
// ** ** ** ** ** ** ** Operations For Exam Schedule ** ** ** ** ** ** **
//----------------------------------------------------------------------------


//Add by Aamir khan sessionid 09-05-2024
async function createExamSchedule(newSchedule) {
  console.log('@#newSchedule==>', newSchedule);
  try {
    const result = await sql.query(
      `INSERT INTO ${this.schema}.exam_schedule (exam_title_id,sessionid,schedule_date, start_time, end_time, duration, room_no, examinor_id, status, subject_id, class_id, max_marks, min_marks, ispractical) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,$14) RETURNING *`,
      [
        newSchedule.exam_title_id,
        newSchedule.sessionid,
        newSchedule.schedule_date,
        newSchedule.start_time,
        newSchedule.end_time,
        newSchedule.duration,
        newSchedule.room_no,
        newSchedule.examinor_id,
        newSchedule.status,
        newSchedule.subject_id,
        newSchedule.class_id,
        newSchedule.max_marks,
        newSchedule.min_marks,
        newSchedule.ispractical,
      ]
    );

    console.log('@#result==>', result);

    if (result.rows.length > 0) {
      return { id: result.rows[0].id, ...newSchedule };
    }
    return null;
  } catch (error) {
    console.log('SessionIdCheck', error)
    throw error;
  }
}

async function getRelatedRecords() {
  try {
    const relatedRecords = [[], [], [], []];

    const getExaminor = await sql.query(
      `SELECT id, CONCAT(salutation, ' ', firstname, ' ', lastname) as examinor_name FROM ${this.schema}.contact where recordtype = 'Teacher'`
    );
    const getSubject = await sql.query(`SELECT id, name as subject_name FROM ${this.schema}.subject`);
    const getClass = await sql.query(`SELECT id, classname as classname FROM ${this.schema}.class  where status = 'active'`);
    const getTitle = await sql.query(`SELECT id, name as title FROM ${this.schema}.exam_title`)

    relatedRecords[0] = getExaminor.rows;
    relatedRecords[1] = getSubject.rows;
    relatedRecords[2] = getClass.rows;
    relatedRecords[3] = getTitle.rows;

    return relatedRecords;
  } catch (error) {
    throw error;
  }
}

//Add by Aamir khan 09-05-2024
async function getExamSchedules() {
  try {
    const result = await sql.query(`SELECT ext.*, TO_CHAR(ext.schedule_date, 'YYYY-MM-DD') AS schedule_date,
		title.name as exam_title_name, title.status as exam_title_status,
		s.year as session, s.id as session_id, CONCAT(con.salutation, ' ', con.firstname, ' ', con.lastname) as examinor_info,
		sub.name as subject_name, cls.classname as class_name
		FROM ${this.schema}.exam_schedule ext
		INNER JOIN ${this.schema}.exam_title title on title.id = ext.exam_title_id
		INNER JOIN ${this.schema}.session s on s.id = ext.sessionid   
		INNER JOIN ${this.schema}.contact con on con.id = ext.examinor_id
		INNER JOIN ${this.schema}.subject sub on sub.id = ext.subject_id 
		INNER JOIN ${this.schema}.class cls on cls.id = ext.class_id`);

    return result.rows;
  } catch (error) {
    console.log('errorCome', error);
    throw error;
  }
}

async function updateExamScheduleById(id, newSchedule) {
  try {
    const existingSchedule = await sql.query(
      `SELECT * FROM ${this.schema}.exam_schedule WHERE id = $1`,
      [id]
    );

    if (existingSchedule.rows.length === 0) {
      return null;
    }

    const result = await sql.query(
      `UPDATE ${this.schema}.
      
      
      
      SET exam_title_id = $1, schedule_date = $2, start_time = $3, end_time = $4, duration = $5, room_no = $6, examinor_id = $7, status = $8, subject_id = $9, class_id = $10, max_marks = $11, min_marks = $12, ispractical = $13 WHERE id = $14 RETURNING *`,
      [
        newSchedule.exam_title_id,
        newSchedule.schedule_date,
        newSchedule.start_time,
        newSchedule.end_time,
        newSchedule.duration,
        newSchedule.room_no,
        newSchedule.examinor_id,
        newSchedule.status,
        newSchedule.subject_id,
        newSchedule.class_id,
        newSchedule.max_marks,
        newSchedule.min_marks,
        newSchedule.ispractical,
        id
      ]
    );

    if (result.rows.length > 0) {
      return { id, ...newSchedule };
    }

    return null;
  } catch (error) {
    throw error;
  }
}

async function getExamScheduleById(id) {
  try {
    const result = await sql.query(
      `SELECT ext.*, TO_CHAR(ext.schedule_date, 'YYYY-MM-DD') AS schedule_date,
        title.name as exam_title_name, title.status as exam_title_status,
        CONCAT(con.salutation, ' ', con.firstname, ' ', con.lastname) as examinor_info,
        sub.name as subject_name, cls.classname as class_name
        FROM ${this.schema}.exam_schedule ext
        INNER JOIN ${this.schema}.exam_title title on title.id = ext.exam_title_id        
        INNER JOIN ${this.schema}.contact con on con.id = ext.examinor_id
        INNER JOIN ${this.schema}.subject sub on sub.id = ext.subject_id 
        INNER JOIN ${this.schema}.class cls on cls.id = ext.class_id
        WHERE ext.id =$1`,

      [id]
    );

    if (result.rows.length > 0) {
      return result.rows[0];
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function getExamScheduleByClassId(classId, admissionId) {
  try {
    const result = await sql.query(
      `SELECT sd.*, title.name as title, cls.classname as classname, sub.name as subject,
        CONCAT(con.salutation, ' ', con.firstname, ' ', con.lastname) as examinor,
        r.obtained_marks as obtained_marks
        FROM ${this.schema}.exam_schedule sd
        INNER JOIN ${this.schema}.exam_title title on title.id = sd.exam_title_id
        INNER JOIN ${this.schema}.class cls on cls.id = sd.class_id
        INNER JOIN ${this.schema}.subject sub on sub.id = sd.subject_id
        INNER JOIN ${this.schema}.contact con on con.id = sd.examinor_id
        LEFT JOIN ${this.schema}.result r on r.exam_schedule_id = sd.id and
        r.student_addmission_id = $1
        WHERE sd.class_id = $2`,
      [admissionId, classId]
    );
    if (result.rows.length > 0) {
      return result.rows[0];
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function deleteExamSchedule(id) {
  try {
    const existingSchedule = await sql.query(
      `SELECT * FROM ${this.schema}.exam_schedule WHERE id = $1`,
      [id]
    );

    if (existingSchedule.rows.length === 0) {
      return null;
    }

    const result = await sql.query(`DELETE FROM ${this.schema}.exam_schedule WHERE id = $1`, [
      id
    ]);

    if (result.rowCount > 0) {
      return { message: "Exam schedule deleted successfully!!!" };
    }

    return null;
  } catch (error) {
    throw error;
  }
}
async function duplicateExamTitleById(name, sessionid) {
  try {
    const result = await sql.query(` select * from ${this.schema}.exam_title where name = $1 and sessionid = $2`, [name, sessionid]);

    if (result.rows.length > 0) {
      return result.rows[0];
    }
    return null;
  } catch (error) {
    console.log('errorthis=>', error);
    throw error;
  }
}
module.exports = {
  createExamTitle,
  getExamTitles,
  updateExamTitleById,
  getExamTitleById,
  deleteExamTitle,
  createExamSchedule,
  getExamSchedules,
  updateExamScheduleById,
  getExamScheduleById,
  deleteExamSchedule,
  getRelatedRecords,
  init,
  getExamScheduleByClassId,
  duplicateExamTitleById

};