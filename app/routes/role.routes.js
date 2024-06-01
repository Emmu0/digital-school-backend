// role.route.js

//const permissions = require("../constants/permissions.js");
const { fetchUser } = require("../middleware/fetchuser.js");
const {
  createRole,
  findRoleById,
  getAllRole,
  deleteRole,
  updateRole,
  checkDuplicateRole,
} = require("../models/role.modal.js");

module.exports = (app) => {
  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();


  // router.post(
  //   "/create",
  //   fetchUser,
  //   [
  //     body("name", "Please provide a name for the role").isLength({ min: 1 }),
  //     body("status", "Please provide a status for the role").isLength({ min: 1 }),
  //   ],
  //   async (req, res) => {


  //     const errors = validationResult(req);
  //     if (!errors.isEmpty()) {
  //       return res.status(400).json({ errors: errors.array() });
  //     }

  //     const roleData = req.body;
  //     const createdRole = await createRole(roleData);

  //     if (!createdRole) {
  //       return res.status(400).json({ errors: "Bad Request" });
  //     }


  //     return res
  //       .status(201)
  //       .json({ message: "Role created successfully", role: createdRole });
  //   }
  // );
  router.post(
    "/create",
    fetchUser,
    [
      body("name", "Please provide a name for the role").isLength({ min: 1 }),
      body("status", "Please provide a status for the role").isLength({
        min: 1,
      }),
    ],
    async (req, res) => {
      

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      const duplicate = await checkDuplicateRole(req.body);
      if (!duplicate) {
        const roleData = req.body;
        const createdRole = await createRole(roleData);

        if (!createdRole) {
          return res.status(400).json({success: false, errors: "Bad Request" });
        }
        return res
          .status(201)
          .json({success: true, message: "Role created successfully", role: createdRole });
      } else {
        return res
          .status(200)
          .json({ success: false, message: "Record already exists." });
      }
    }
  );
  // Add a route to update a specific fare by ID (PUT)
  //   router.put("/updatebyid/:id", fetchUser, [
  //     body("name", "Please provide a name for the role").isLength({ min: 1 }),
  //     body("status", "Please provide a status for the role").isLength({ min: 1 }),
  // ], async (req, res) => {
  //     try {
  

  //         const errors = validationResult(req);
  //         if (!errors.isEmpty()) {
  //             return res.status(400).json({ errors: errors.array() });
  //         }

  //         const RoleId = req.params.id;
  //         const UpdatedRoleData = req.body;


  //         const updatedRole = await updateRole(RoleId, UpdatedRoleData);

  //         if (updatedRole) {
  //             return res.status(200).json({ message: "Role updated successfully", Role: updatedRole });
  //         } else {
  //             return res.status(404).json({ errors: "Role not found" });
  //         }
  //     } catch (error) {
  //         console.error('System Error:', error);
  //         return res.status(500).json({ errors: "Internal Server Error" });
  //     }
  // });

  router.put(
    "/updatebyid/:id",
    fetchUser,
    [
      body("name", "Please provide a name for the role").isLength({ min: 1 }),
      body("status", "Please provide a status for the role").isLength({
        min: 1,
      }),
    ],
    async (req, res) => {
      try {
       

        const errors = validationResult(req);
        if (!errors.isEmpty()) {
          return res.status(400).json({success: false, errors: errors.array() });
        }

        const duplicate = await checkDuplicateRole(req.body);
        if (!duplicate) {
          const RoleId = req.params.id;
          const UpdatedRoleData = req.body;

          const updatedRole = await updateRole(RoleId, UpdatedRoleData);

          if (updatedRole) {
            return res
              .status(200)
              .json({
                success: true,
                message: "Role updated successfully",
                Role: updatedRole,
              });
          } else {
            return res.status(404).json({success: false, errors: "Role not found" });
          }
        } else {
          return res
            .status(200)
            .json({ success: false, message: "Record already exists." });
        }
      } catch (error) {
        console.error("System Error:", error);
        return res.status(500).json({success: false, errors: "Internal Server Error" });
      }
    }
  );

  router.get("/getrole", fetchUser, async (req, res) => {
    try {


      const allRoles = await getAllRole();

      if (allRoles) {
        res.status(200).json(allRoles);
      } else {
        res.status(400).json({ errors: "No data" });
      }
    } catch (error) {
      console.error("Error in /role route:", error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });


  router.get("/getrolebyid/:id", fetchUser, async (req, res) => {
    try {

      

      const roleId = req.params.id;
      const role = await findRoleById(roleId);

      if (role) {
        return res.status(200).json(role);
      } else {
        return res.status(404).json({ errors: "Role not found" });
      }
    } catch (error) {
      console.error('System Error:', error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });


  router.delete("/deleterolebyid/:id", fetchUser, async (req, res) => {
    try {

      

      const roleId = req.params.id;
      const deletedRole = await deleteRole(roleId);
      if (deletedRole.error) {
        return res.status(404).json({ errors: deletedRole.error });
      }
      if (deletedRole.success) {
        return res.status(200).json({ message: "Role deleted successfully" });
      } else {
        return res.status(404).json({ errors: "Role not found" });
      }
    } catch (error) {
      console.error('System Error:', error);
      return res.status(500).json({ errors: "Internal Server Error" });
    }
  });

  app.use(process.env.BASE_API_URL + "/api/rolemaster", router);
};
