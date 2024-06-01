// role.route.js

//const permissions = require("../constants/permissions.js");
const { fetchUser } = require("../middleware/fetchuser.js");
const {
  createModule,
  findModuleById,
  getAllModule,
  deleteModule,
  updateModule,
  duplicateModuleRecord,
} = require("../models/module.modal.js");
const sql = require("../models/db.js");

module.exports = (app) => {
  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  router.post(
    "/create",
    fetchUser,
    [
      // body("name", "Please provide a name for the role").isLength({ min: 1 }),
      // body("status", "Please provide a status for the role").isLength({ min: 1 }),
    ],
    async (req, res) => {

      
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const moduleData = req.body;

      let duplicate = await duplicateModuleRecord(null, moduleData);

      if (duplicate === null) {
        const result = await createModule(moduleData);
        if (result) {
          return res.status(200).json({ "success": true, "result": result, "message": "Module created successfully" });
        } else {
          return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
      } else {
        return res.status(200).json({ "success": false, "message": "Record already exists." });
      }
    }
  );



  router.get("/getmodule/:companyid", fetchUser, async (req, res) => {
    try {

      const allRoles = await getAllModule(req.params.companyid);

      if (allRoles) {
        res.status(200).json(allRoles);
      } else {
        res.status(400).json({ errors: "No data" });
      }
    } catch (error) {
      console.error("Error in /module route:", error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });


  router.get("/getid/:id", fetchUser, async (req, res) => {
    try {

      

      const roleId = req.params.id;
      const role = await findModuleById(roleId);

      if (role) {
        return res.status(200).json(role);
      } else {
        return res.status(404).json({ errors: "module not found" });
      }
    } catch (error) {
      console.error('System Error:', error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });


  router.delete("/delete/:id", fetchUser, async (req, res) => {
    try {

     

      const moduleId = req.params.id;
      const deletedModule = await deleteModule(moduleId);
      if (deletedModule.error) {
        return res.status(404).json({ errors: deletedModule.error });
      }
      if (deletedModule.success) {
        return res.status(200).json({ message: "module deleted successfully" });
      } else {
        return res.status(404).json({ errors: "module not found" });
      }
    } catch (error) {
      console.error('System Error:', error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });

  router.put("/updatebyid/:id", fetchUser, [
    body("name", "Please provide a name for the role").isLength({ min: 1 }),
    body("status", "Please provide a status for the role").isLength({ min: 1 }),
  ], async (req, res) => {
    try {
      

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const ModuleId = req.params.id;
      const UpdatedModuleData = req.body;

      let duplicate = await duplicateModuleRecord(ModuleId, UpdatedModuleData);

      if (duplicate === null) {
        const result = await updateModule(ModuleId, UpdatedModuleData);
        if (result) {
          return res.status(200).json({ "success": true, "result": result, "message": "Module updated successfully" });
        } else {
          return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
      } else {
        return res.status(200).json({ "success": false, "message": "Record already exists." });
      }
    } catch (error) {
      console.error('System Error:', error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });

  app.use(process.env.BASE_API_URL + "/api/modulemaster", router);
};
