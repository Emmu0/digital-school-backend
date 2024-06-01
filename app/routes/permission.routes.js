//const permissions = require("../constants/permissions.js");
const { fetchUser } = require("../middleware/fetchuser.js");
const {
    createPermission,
    updatePermission,
    deletePermission,
    CheckDuplicatePermission,
   
  } = require("../models/permission.modal.js");

  module.exports = (app) => {
    const { body, validationResult } = require("express-validator");

    var router = require("express").Router();


    // router.post(
    //     "/create",
    //     fetchUser,
    //     [
    //       body("name", "Please provide a name for the role").isLength({ min: 1 }),
    //       body("status", "Please provide a status for the role").isLength({ min: 1 }),
    //     ],
    //     async (req, res) => {
    
    //       const errors = validationResult(req);
    //       if (!errors.isEmpty()) {
    //         return res.status(400).json({ errors: errors.array() });
    //       }
    
    //       const permissionData = req.body;
    //       const createdPermission = await createPermission(permissionData);
    
    //       if (!createdPermission) {
    //         return res.status(400).json({ errors: "Bad Request" });
    //       }
    
    //       return res
    //         .status(201)
    //         .json({ message: "Permission created successfully", permission: createdPermission });
    //     }
    //   );

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
        const duplicate = await CheckDuplicatePermission(req.body);
        console.log(duplicate,'duplicate&&');
        if (!duplicate) {
          const permissionData = req.body;
          const createdPermission = await createPermission(permissionData);
  
          if (!createdPermission) {
            return res.status(400).json({ errors: "Bad Request" });
          }
  
          return res.status(201).json({
            message: "Permission created successfully",
            permission: createdPermission,
          });
        } else {
          return res
            .status(200)
            .json({ success: false, message: "Record already exists." });
        }
      }
    );  


    //   router.put("/updatebyid/:id", fetchUser, [
    //     body("name", "Please provide a name for the role").isLength({ min: 1 }),
    //     body("status", "Please provide a status for the role").isLength({ min: 1 }),
    // ], async (req, res) => {
    //     try {
    //       
    //         const errors = validationResult(req);
    //         if (!errors.isEmpty()) {
    //             return res.status(400).json({ errors: errors.array() });
    //         }
    
    //         const permissionId = req.params.id;
    //         const updatePermissionData = req.body;
    
          
    //         const updatedPermission = await updatePermission(permissionId, updatePermissionData);
    
    //         if (updatedPermission) {
    //             return res.status(200).json({ message: "Permission updated successfully", Permission: updatedPermission });
    //         } else {
    //             return res.status(404).json({ errors: "Permission not found" });
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
            return res.status(400).json({ errors: errors.array() });
          }
          const duplicate = await CheckDuplicatePermission(req.body);
          console.log(duplicate,'duplicate');
          if(!duplicate){
            const permissionId = req.params.id;
            const updatePermissionData = req.body;
    
            const updatedPermission = await updatePermission(
              permissionId,
              updatePermissionData
            );
    
            if (updatedPermission) {
              return res.status(200).json({
                message: "Permission updated successfully",
                Permission: updatedPermission,
              });
            } else {
              return res.status(404).json({ errors: "Permission not found" });
            }
          }else{
            return res
            .status(200)
            .json({ success: false, message: "Record already exists." });
          }
          
        } catch (error) {
          console.error("System Error:", error);
          return res.status(500).json({ errors: "Internal Server Error" });
        }
      }
    );


    router.delete("/deletepermissionbyid/:id", fetchUser, async (req, res) => {
        try {
         
          
    
          const permissionId = req.params.id;
          const deletedPermission = await deletePermission(permissionId);
          if (deletedPermission.error) {
            return res.status(404).json({ errors: deletedPermission.error });
          }
          if (deletedPermission.success) {
            return res.status(200).json({ message: "Permission deleted successfully" });
          } else {
            return res.status(404).json({ errors: "Permission not found" });
          }
        } catch (error) {
          console.error('System Error:', error);
          return res.status(500).json({ errors: "Internal Server Error" });
        }
      });

    app.use(process.env.BASE_API_URL + "/api/permission", router);
};