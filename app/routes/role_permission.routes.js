// added by the Shivam Shrivastava
// updated code changes by shahir hussain 22-04-2024

//const permissions = require("../constants/permissions.js");
const { fetchUser } = require("../middleware/fetchuser.js");
const Module = require("../models/module.modal.js")
const Role = require("../models/role.modal.js")
//getAllRole
const {
  findById,
  deleteRolePermission,
  getRolePermissions,
  upsertRecords
} = require("../models/role_permission.model.js");

module.exports = (app) => {
  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  //created by abdul sir 19-04-2024
  router.get("/:companyid", fetchUser, async (req, res) => {
    const modules = await Module.getAllModule(req.params.companyid);
    const roles = await Role.getAllRole();
    console.log(roles);
    const rolePermisionsRecords = await getRolePermissions();
    if (roles) {
      const result = roles.map((role, index) => {
        const rolePermission = { id: role.id, name: role.name, permissions: [] };

        modules.forEach(module => {
          let permission = {
            id: null,
            moduleid: module.id,
            module_name: module.name,
            roleid: role.id,
            can_create: null,
            can_read: null,
            can_edit: null,
            can_delete: null,
            view_all: null,
            modify_all: null
          };
          if (rolePermisionsRecords) {
            const rolePermission = rolePermisionsRecords.find((rp) => rp.roleid == role.id && rp.moduleid == module.id);
            console.log("rolepermissin: ", rolePermission);
            if (rolePermission) {
              permission.id = rolePermission.id;
              permission.can_create = rolePermission.can_create;
              permission.can_edit = rolePermission.can_edit;
              permission.can_read = rolePermission.can_read;
              permission.can_delete = rolePermission.can_delete;
              permission.view_all = rolePermission.view_all;
              permission.modify_all = rolePermission.modify_all;
            }
          }
          rolePermission.permissions.push(permission);

        });
        console.log("rolePermission: ", rolePermission);
        return rolePermission;
      }
      )
      return res.status(200).json(result);
    }
    return res.status(400).json({ errors: "No data" });
  }),

    router.post("/", fetchUser, async (req, res) => {
      const errors = validationResult(req);

      // console.log('insie thebpost222',errors)
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      //   console.log('req.bodyySTTTTT88=>', req.body)

      console.log("databody", req.body);
      let result = await upsertRecords(req.body);
      console.log("result", result);
      if (result) {
        return res.status(200).json(result);
      } else {
        return res.status(200).json({ success: false, message: "Bad Request" });
      }
    });

  router.get("/getbyid/:id", fetchUser, async (req, res) => {
    try {

    

      const roleId = req.params.id;
      const role = await findById(roleId);

      if (role) {
        return res.status(200).json(role);
      } else {
        return res.status(404).json({ errors: "role_permission not found" });
      }
    } catch (error) {
      console.error('System Error:', error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });


  router.delete("/deletebyid/:id", fetchUser, async (req, res) => {
    try {

    
      const roleId = req.params.id;
      const deletedRole = await deleteRolePermission(roleId);

      if (deletedRole) {
        return res.status(200).json({ message: "role_permission deleted successfully" });
      } else {
        return res.status(404).json({ errors: "role_permission not found" });
      }
    } catch (error) {
      console.error('System Error:', error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });

  app.use(process.env.BASE_API_URL + "/api/permissions", router);
};