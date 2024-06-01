const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}

async function createUser(newUser) {
  const { firstname, lastname, email, password } = newUser;
  const result = await sql.query("INSERT into public.user (firstname, lastname, email, password) VALUES ($1, $2, $3, $4) RETURNING id, firstname, lastname, email, password", [firstname, lastname, email, password]);
  if (result.rowCount > 0) {
    return result.rows[0];
  }
  return null;

};

async function findByEmail(email, schoolcode, type) {


  if (type === 'PARENT' || type === 'STUDENT') {

    const isSchool = await sql.query(`select * from public.company where tenantcode = $1`, [schoolcode])

    console.log('isSchool', isSchool);
    if (isSchool.rows.length < 1) {
      return null;
    }

    const result = await sql.query(`select 
  json_build_object(
      'id', u.id,
      'firstname', u.firstname,
      'lastname', u.lastname,
      'email', u.email,
      'phone', u.phone,
      'password', u.password,
      'companyid', u.companyid,          
      'password', u.password,
      'companyname', c.name,
      'companystreet', c.street,
      'companycity', c.city,
      'companypincode', c.pincode,
      'companystate', c.state,
      'companycountry', c.country,
      'tenantcode', c.tenantcode,
      'logourl', c.logourl,
      'sidebarbgurl', c.sidebarbgurl
    ) AS userinfo
  from ${schoolcode}.user u
  INNER JOIN public.COMPANY c ON c.id = u.companyid
  where u.type = $1 AND u.email = $2
  GROUP BY u.id, u.firstname, u.lastname, u.email, u.password, u.password, c.name, c.street, c.city, c.pincode, c.state, c.country, c.tenantcode, c.logourl, c.sidebarbgurl`, [type, email]);

    console.log('result after query', result);
    if (result.rows.length > 0)
      return result.rows[0];
    return null;
  }
  else {
    let query = `select
    json_build_object(
            'id', u.id,
            'firstname', u.firstname,
            'lastname', u.lastname,
            'email', u.email,
            'password', u.password,
            'userrole', u.userrole,
            'companyid', u.companyid,          
            'password', u.password,
            'companyname', c.name,
            'companystreet', c.street,
            'companycity', c.city,
            'companypincode', c.pincode,
            'companystate', c.state,
            'companycountry', c.country,
            'tenantcode', c.tenantcode,
            'logourl', c.logourl,
            'sidebarbgurl', c.sidebarbgurl,
            'permissions', ''
  ) AS userinfo
  FROM public.user u
  
  INNER JOIN public.COMPANY c ON u.companyid = c.id
  WHERE u.email = $1`;
    console.log("Query => ", query, type);
    console.log("emailid", email);
    console.log("emailid_query", query);
    const result = await sql.query(query, [email]);


    if (result.rows.length > 0)
      return result.rows[0];
    return null;
  }



};



async function findById(id) {

  try {
    const result = await sql.query(`SELECT id, email, firstname, lastname, phone FROM public.user WHERE id = $1`, [id]);
    if (result.rows.length > 0)
      return result.rows[0];
  } catch (error) {
    console.log("error ", error);
  }

  return null;
};

async function findSchemaUserById(id, tenantcode) {

  try {
    const result = await sql.query(`SELECT id, email, firstname, lastname, phone FROM ${tenantcode}.user WHERE id = $1`, [id]);
    if (result.rows.length > 0)
      return result.rows[0];
  } catch (error) {
    console.log("error ", error);
  }

  return null;
};

async function updateById(id, userRec) {
  try {
    const result = await sql.query(`UPDATE public.user SET password = $1 WHERE id = $2`, [userRec.password, id]);
    if (result.rowCount > 0)
      return "Updated successfully";
  } catch (error) {
    console.log("error ", error);
  }

  return null;
};

async function findAll() {
  try {
    const result = await sql.query("SELECT id, concat(firstname, ' ' ,lastname) username FROM public.user");

    if (result.rows.length > 0)
      return result.rows;

  } catch (error) {
    console.log("error ", error);
  }

  return null;
};

//.........................................Update user....................
async function updateRecById(id, userRec, userid) {
  delete userRec.id;

  const query = buildUpdateQuery(id, userRec);

  var colValues = Object.keys(userRec).map(function (key) {
    return userRec[key];
  });
  const result = await sql.query(query, colValues);
  if (result.rowCount > 0) {
    return { "id": id, ...userRec };
  }
  return null;
};



function buildUpdateQuery(id, cols) {

  var query = ['UPDATE public.user '];
  query.push('SET');


  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + ' = ($' + (i + 1) + ')');
  });
  query.push(set.join(', '));

  query.push('WHERE id = \'' + id + '\'');


  return query.join(' ');
};

module.exports = { createUser, findByEmail, findById, findAll, updateById, updateRecById, init, findSchemaUserById };
