/**
 * @author: Pawan Singh Sisodiya
 */

const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}
// ** ** ** ** ** ** ** Operations For Grade Master ** ** ** ** ** ** **

async function createGradeMaster(newGrade) {
  try {
    const result = await sql.query(
      `INSERT INTO ${this.schema}.grade_master (grade, "from", "to") VALUES ($1, $2, $3) RETURNING *`,
      [newGrade.grade, newGrade.from, newGrade.to]
    );

    if (result.rows.length > 0) {
      return { id: result.rows[0].id, ...newGrade };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

//------------------ Get All Grades -----------------------
async function getGradeMasters() {
  try {
    const result = await sql.query(`SELECT * FROM ${this.schema}.grade_master`);
    return result.rows;
  } catch (error) {
    throw error;
  }
}

// ------------------ Get Grade by ID -----------------------
async function getGradeMasterById(gradeId) {
  try {
    const result = await sql.query(
      `SELECT * FROM ${this.schema}.grade_master WHERE id = $1`,
      [gradeId]
    );
    return result.rows[0];
  } catch (error) {
    throw error;
  }
}

// ------------------------- Update Grade by ID --------------------
async function updateGradeMasterById(gradeId, updatedGrade) {
  try {
    const result = await sql.query(
      `UPDATE ${this.schema}.grade_master SET grade = $1, "from" = $2, "to" = $3 WHERE id = $4 RETURNING *`,
      [updatedGrade.grade, updatedGrade.from, updatedGrade.to, gradeId]
    );

    if (result.rows.length > 0) {
      return { id: result.rows[0].id, ...updatedGrade };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

// --------------------- Delete Grade by ID ------------------------
async function deleteGradeMaster(gradeId) {
  try {
    const result = await sql.query(
      `DELETE FROM ${this.schema}.grade_master WHERE id = $1`,
      [gradeId]
    );
    return result.rowCount > 0;
  } catch (error) {
    throw error;
  }
}

// Create a new result
async function createResult(resultData) {
  try {
    const result = await sql.query(
      `INSERT INTO "${this.schema}.result" ("exam_schedule_id", "student_addmission_id", "obtained_marks", "ispresent", "grade_master_id") VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [
        resultData.exam_schedule_id,
        resultData.student_admissionid,
        resultData.obtained_marks,
        resultData.ispresent,
        resultData.grade_master_id,
      ]
    );

    if (result.rows.length > 0) {
      return result.rows[0];
    }
    return null;
  } catch (error) {
    throw error;
  }
}

// Get all results
async function getAllResults() {
  try {
    const result = await sql.query(`SELECT * FROM "${this.schema}.result"`);
    return result.rows;
  } catch (error) {
    throw error;
  }
}

// Get result by ID
async function getResultById(scheduleId, classId) {


  try {
    const result = await sql.query(
      `SELECT student.id AS student_id, student_addmission.id as student_admissionid,
      CONCAT(student.firstname, ' ', student.lastname) AS student_name, result.id AS resultid,
      result.obtained_marks AS obtained_marks, result.ispresent AS ispresent
      FROM ${this.schema}.student
      INNER JOIN ${this.schema}.student_addmission ON student.id = student_addmission.studentid
      INNER JOIN ${this.schema}.exam_schedule ON student.classid = exam_schedule.class_id
      LEFT JOIN ${this.schema}.result ON student_addmission.id = result.student_addmission_id
      AND exam_schedule.id = result.exam_schedule_id
      WHERE exam_schedule.id = $1 AND student.classid = $2;`,
      [scheduleId, classId]
    );


    return result.rows;
  } catch (error) {
    throw error;
  }
}

// Update result by ID
async function updateResultById(id, updatedResultData) {
  try {
    const result = await sql.query(
      `UPDATE "result" SET "${this.schema}.exam_schedule_id" = $1, "student_addmission_id" = $2, "obtained_marks" = $3, "ispresent" = $4, "grade_master_id" = $5 WHERE id = $6 RETURNING *`,
      [
        updatedResultData.exam_schedule_id,
        updatedResultData.student_admissionid,
        updatedResultData.obtained_marks,
        updatedResultData.ispresent,
        updatedResultData.grade_master_id,
        id,
      ]
    );

    if (result.rows.length > 0) {
      return result.rows[0];
    }
    return null;
  } catch (error) {
    throw error;
  }
}

// Delete result by ID
async function deleteResultById(resultId) {
  try {
    const result = await sql.query(
      `DELETE FROM "${this.schema}.result" WHERE id = $1`,
      [resultId]
    );
    return result.rowCount > 0;
  } catch (error) {
    throw error;
  }
}

async function updateAllResult(updatedResultDataArray) {
  const updatePromises = updatedResultDataArray.map(
    async (updatedResultData) => {
      try {
        if (!updatedResultData.resultid) {
          throw new Error("Invalid resultid: Empty UUID");
        }


        const query = `
        UPDATE ${this.schema}.result
        SET
        exam_schedule_id = $2,
        student_addmission_id = $3,
        obtained_marks = $4,
        ispresent = $5,
        grade_master_id = $6
        WHERE
        id = $1
        RETURNING *;`;

        const values = [
          updatedResultData.resultid,
          updatedResultData.exam_schedule_id,
          updatedResultData.student_admissionid,
          updatedResultData.obtained_marks,
          updatedResultData.ispresent,
          updatedResultData.grade_master_id,
        ];

        const result = await sql.query(query, values);

        return result.rows.length > 0 ? result.rows[0] : null;
      } catch (error) {

        throw error;
      }
    }
  );
  try {

    const updatedResults = await Promise.all(updatePromises);
    return updatedResults.filter(result => result !== null);
  } catch (error) {
    console.error("Error updating results:", error);
  }
}

async function CreateAllResult(CreateResutArray) {
  const createResult = CreateResutArray.map(async (resultData) => {
    try {


      const query = `
      INSERT INTO 
      ${this.schema}.result 
      (exam_schedule_id, 
      student_addmission_id, 
      obtained_marks, ispresent
      , grade_master_id) VALUES 
      ($1, $2, $3, $4, $5) RETURNING *;`;
      const values = [
        resultData.exam_schedule_id,
        resultData.student_admissionid,
        resultData.obtained_marks,
        resultData.ispresent,
        resultData.grade_master_id,
      ];

      const result = await sql.query(query, values);

      return result.rows.length > 0 ? result.rows[0] : null;
    } catch (error) {

      throw error;
    }
  });
  try {
    const createResultResponse = createResult;

    return createResultResponse;
  } catch (error) {
    console.error("Error updating results:", error);
  }

  try {
    const result = await sql.query(
      `INSERT INTO "${this.schema}.result" ("exam_schedule_id", "student_addmission_id", "obtained_marks", "ispresent", "grade_master_id") VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [
        resultData.exam_schedule_id,
        resultData.student_admissionid,
        resultData.obtained_marks,
        resultData.ispresent,
        resultData.grade_master_id,
      ]
    );

    if (result.rows.length > 0) {
      return result.rows[0];
    }
    return null;
  } catch (error) {
    throw error;
  }
}

module.exports = {
  createGradeMaster,
  getGradeMasters,
  getGradeMasterById,
  updateGradeMasterById,
  deleteGradeMaster,
  createResult,
  getAllResults,
  getResultById,
  updateResultById,
  deleteResultById,
  updateAllResult,
  CreateAllResult,
  init,
};
