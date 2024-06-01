/**
 * @author: Pawan Singh Sisodiya
 */

const sql = require("./db.js");
let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}
// ** ** ** ** ** ** ** Operations For Session ** ** ** ** ** ** **

async function createSession(newSession) {

  try {
    const result = await sql.query(
      `INSERT INTO ${this.schema}.session (year, startdate, enddate) VALUES ($1, $2, $3) RETURNING *`,
      [newSession.year, newSession.startdate, newSession.enddate]
    );

    if (result.rows.length > 0) {
      return { id: result.rows[0].id, ...newSession };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function getSession() {
  try {
    const result = await sql.query(`SELECT * FROM ${this.schema}.session`);

    result.rows.map((sessionRec) => {
      sessionRec.startdate.setDate(sessionRec.startdate.getDate() + 1);
      sessionRec.startdate = sessionRec.startdate.toISOString().split('T')[0];

      sessionRec.enddate.setDate(sessionRec.enddate.getDate() + 1);
      sessionRec.enddate = sessionRec.enddate.toISOString().split('T')[0];
    })
    return result.rows;
  } catch (error) {
    throw error;
  }
}

async function updateSessionById(id, newSession) {
  try {
    const existingSession = await sql.query(`SELECT * FROM ${this.schema}.session WHERE id = $1`, [id]);

    if (existingSession.rows.length === 0) {
      return null;
    }

    // Update the session with the new data
    const result = await sql.query(
      `UPDATE ${this.schema}.session SET year = $1, startdate = $2, enddate = $3 WHERE id = $4 RETURNING *`,
      [newSession.year, newSession.startdate, newSession.enddate, id]
    );

    if (result.rows.length > 0) {
      return { id, ...newSession };
    }

    return null;
  } catch (error) {
    throw error;
  }
}

async function getSessionById(id) {
  try {
    const result = await sql.query(`SELECT * FROM ${this.schema}.session WHERE id = $1`, [id]);
    result.rows.map((sessionRec)=>{
      console.log('sessionRec ======>',sessionRec);
      sessionRec.startdate.setDate(sessionRec.startdate.getDate()+1);
      sessionRec.startdate = sessionRec.startdate.toISOString().split('T')[0];

      sessionRec.enddate.setDate(sessionRec.enddate.getDate()+1);
      sessionRec.enddate = sessionRec.enddate.toISOString().split('T')[0];
    })
    if (result.rows) {
      return result.rows[0];
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function deleteSession(id) {
  try {
    const existingSession = await sql.query(`SELECT * FROM ${this.schema}.session WHERE id = $1`, [id]);

    if (existingSession.rows.length === 0) {
      return null;
    }

    const result = await sql.query(`DELETE FROM ${this.schema}.session WHERE id = $1`, [id]);

    if (result.rowCount > 0) {
      return { message: "Session deleted successfully!!!" };
    }

    return null;
  } catch (error) {
    throw error;
  }
}

// ** ** ** ** ** ** ** Operations For Session Term ** ** ** ** ** ** **

async function createSessionTerm(newSessionTerm) {
  try {
    const result = await sql.query(
      `INSERT INTO ${this.schema}.session_term (name, startdate, enddate, sessionid, status) VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [newSessionTerm.name, newSessionTerm.startdate, newSessionTerm.enddate, newSessionTerm.sessionid, newSessionTerm.status]
    );

    if (result.rows.length > 0) {
      return { id: result.rows[0].id, ...newSessionTerm };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function getSessionTerms() {
  try {
    const result = await sql.query(`SELECT * FROM ${this.schema}.session_term`);

    return result.rows;
  } catch (error) {
    throw error;
  }
}

async function updateSessionTermById(id, newSessionTerm) {
  try {
    const existingSessionTerm = await sql.query(`SELECT * FROM ${this.schema}.session_term WHERE id = $1`, [id]);

    if (existingSessionTerm.rows.length === 0) {
      return null;
    }

    // Update the session_term with the new data
    const result = await sql.query(
      `UPDATE ${this.schema}.session_term SET name = $1, startdate = $2, enddate = $3, sessionid = $4, status = $5 WHERE id = $6 RETURNING *`,
      [newSessionTerm.name, newSessionTerm.startdate, newSessionTerm.enddate, newSessionTerm.sessionid, newSessionTerm.status, id]
    );

    if (result.rows.length > 0) {
      return { id, ...newSessionTerm };
    }

    return null;
  } catch (error) {
    throw error;
  }
}

async function getSessionTermById(id) {
  try {
    const result = await sql.query(`SELECT * FROM ${this.schema}.session_term WHERE id = $1`, [id]);

    if (result.rows.length > 0) {
      return result.rows[0];
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function deleteSessionTerm(id) {
  try {
    const existingSessionTerm = await sql.query(`SELECT * FROM ${this.schema}.session_term WHERE id = $1`, [id]);

    if (existingSessionTerm.rows.length === 0) {
      return null;
    }

    const result = await sql.query(`DELETE FROM ${this.schema}.session_term WHERE id = $1`, [id]);

    if (result.rowCount > 0) {
      return { message: "Session term deleted successfully!!!" };
    }

    return null;
  } catch (error) {
    throw error;
  }
}

module.exports = {
  createSession,
  getSession,
  updateSessionById,
  getSessionById,
  deleteSession,
  createSessionTerm,
  getSessionTerms,
  updateSessionTermById,
  getSessionTermById,
  deleteSessionTerm,
  init
};
