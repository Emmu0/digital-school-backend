
// added by the shakib khan 
const sql = require("./db.js");


// Create Module
async function createModule(newModule) {
  // delete newRole.id;
  console.log('newModule.parentid=====>', newModule);
  let parent_module = null;
  if (newModule.parent_module === '') {
    parent_module = null;
  } else {
    parent_module = newModule.parent_module;
  }

  const order_no = newModule.order_no !== null ? parseInt(newModule.order_no) : null;

  const result = await sql.query("INSERT INTO module (name, status,api_name,icon,url,parent_module,icon_type,order_no) VALUES ($1, $2,$3,$4,$5,$6,$7,$8) RETURNING *",
    [newModule.name, newModule.status, newModule.api_name, newModule.icon, newModule.url, parent_module, newModule.icon_type, order_no]);
  console.log('create module result===>', result.rows);
const companyModule = await sql.query('INSERT INTO public.company_module (companyid, moduleid) VALUES ($1, $2) RETURNING *',[newModule.CompanyId,result.rows[0].id])

  if (result.rows.length > 0 && companyModule.rows.length > 0) {
    return { id: result.rows[0].id, ...newModule };
  }
  return null;
}




// Find Role By Id
async function findModuleById(id) {
  const result = await sql.query("SELECT * FROM module WHERE id = $1", [id]);

  if (result.rows.length > 0) {
    return result.rows[0];
  }

  return null;
}
// `SELECT module.*
// FROM public.company_module AS c_module
// INNER JOIN public.module AS module ON module.id = c_module.moduleid
// WHERE c_module.companyid = ${'f3293150-984e-4ac4-94eb-549e1f2af609'} ORDER BY module.order_no`
async function getAllModule(id) {
  if(id){
    const result = await sql.query(`SELECT module.*
    FROM public.company_module AS c_module
    INNER JOIN public.module AS module ON module.id = c_module.moduleid
    WHERE c_module.companyid = '${id}' ORDER BY module.order_no`);
    console.log('result-------->>>>>>', result)
    if (result.rows.length > 0) {
      return result.rows;
    }
  }
  return "No Data Found"
}
async function deleteModule(id) {
  try {
    const moduleExistance = await sql.query('select id from role_permission where moduleid = $1', [id]);
    if (moduleExistance.rowCount > 0) {
      return { 'error': 'Record has refrence in another table, Deletion not allowed' };
    }
    const result = await sql.query(
      "DELETE FROM module WHERE id = $1 RETURNING *",
      [id]
    );

    const resultCompanyModule = await sql.query(
      "DELETE FROM company_module WHERE moduleid = $1 RETURNING *",
      [id]
    );
console.log(resultCompanyModule,'resultCompanyModule');
    if (result.rows.length === 1) {
      return { 'success': result.rows[0] };
    }
    return null;
  } catch (error) {
    throw error;
  }
}
async function updateModule(id, updatedModule) {
  try {
    const result = await sql.query(
      "UPDATE module SET name = $1, status = $2, api_name = $3, icon = $4, url = $5, parent_module = $6, icon_type = $7, order_no = $8 WHERE id = $9 RETURNING *",
      [updatedModule.name, updatedModule.status, updatedModule.api_name, updatedModule.icon, updatedModule.url, updatedModule.parent_module, updatedModule.icon_type, updatedModule.order_no, id]
    );

    if (result.rows.length === 1) {
      return result.rows[0];
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function duplicateModuleRecord(id, request) {
  let query = `SELECT id, name FROM module`

  if (id) {
    query += ` WHERE id != '${id}' AND name = '${request.name}' `;
  } else if (request.name) {
    query += ` WHERE name = '${request.name}'`;
  }
  const result = await sql.query(query);
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}
module.exports = { createModule, deleteModule, getAllModule, findModuleById, updateModule, duplicateModuleRecord }
