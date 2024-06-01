const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}

async function CreateEvent(newEvent) {
  const result = await sql.query(`INSERT INTO ${this.schema}.events (title,event_type,start_date,start_time,end_date,end_time,description,colorcode)  VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
    [newEvent.title, newEvent.event_type, newEvent.start_date, newEvent.start_time, newEvent.end_date, newEvent.end_time, newEvent.description, newEvent.colorcode]);

  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
};

async function updateEventById(id, newEvent) {
  try {
    const existingEvents = await sql.query(`SELECT * FROM ${this.schema}.events WHERE id = $1`, [id]);
    if (existingEvents.rows.length === 0) {
      return null;
    }
    const result = await sql.query(
      `UPDATE ${this.schema}.events SET title = $1,event_type = $2, start_date = $3, start_time = $4, end_date = $5, end_time = $6, description = $7, colorcode =$8 WHERE id = $9 RETURNING *`,
      [newEvent.title, newEvent.event_type, newEvent.start_date, newEvent.start_time, newEvent.end_date, newEvent.end_time, newEvent.description, newEvent.colorcode, id]
    );

    if (result.rows.length > 0) {
      return { id, ...newEvent };
    }
    return null;
  } catch (error) {
    throw error;
  }
}


async function findAllEvents() {
  try {
    const query = `SELECT * FROM ${this.schema}.events`;


    const { rows } = await sql.query(query);
    rows.map((i) => {
      i.start_date.setDate(i.start_date.getDate() + 1);
      i.start_date = i.start_date.toISOString().split('T')[0];
      i.end_date.setDate(i.end_date.getDate() + 1);
      i.end_date = i.end_date.toISOString().split('T')[0];

      i.end_date_model = new Date(i.end_date);
      i.end_date_model.setDate(i.end_date_model.getDate() + 1);
      i.end_date_model = i.end_date_model.toISOString().split('T')[0];
    })

    if (rows.length > 0) {
      return rows;
    } else {
      return null;
    }
  } catch (error) {

    throw error;
  }
}

async function deleteEvent(id) {
  const result = await sql.query(`DELETE FROM ${this.schema}.events WHERE id = $1`, [id]);

  if (result.rowCount > 0)
    return "Success"
  return null;
};


async function EventFindById(id) {
  try {
    const result = await sql.query(
      `SELECT title, event_type, start_date, start_time, end_date, end_time, description
         FROM ${this.schema}.events
         WHERE id = $1`,
      [id]
    );

    if (result.rows.length > 0) {
      return result.rows;
    }
    return null;
  } catch (error) {
    throw error;
  }
}



module.exports = {
  CreateEvent,
  updateEventById,
  findAllEvents,
  deleteEvent,
  EventFindById,
  init
};
