const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Assingment = require("../models/assingment.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = app => {

  const { body, validationResult } = require("express-validator");
  var router = require("express").Router();

  // ................................ Create a new assignment ................................
  router.post("/", fetchUser, [],
    async (req, res) => {

      
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      Assingment.init(req.userinfo.tenantcode);
      const assignmentRecord = await Assingment.CreateAssignemt(req.body);
      if (!assignmentRecord) {
        return res.status(200).json({ message: 'This record already exists' });
      }
      return res.status(201).json(assignmentRecord);
    }
  );

  //------------------------- Update Assignment ---------------------

  router.put("/:id", fetchUser,
    [

    ],
    async (req, res) => {
      

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const assignmentId = req.params.id;

      const assignmentData = req.body;

      Assingment.init(req.userinfo.tenantcode);
      const updateAssignment = await Assingment.updateAssignmentById(assignmentId, assignmentData);

      if (!updateAssignment) {
        return res.status(201).json({ message: "This record already exists" });
      }
      return res.status(200).json(updateAssignment);
    }
  );




  router.get("/assignments", fetchUser, async (req, res) => {
    try {

      
          

      Assingment.init(req.userinfo.tenantcode);

      const { sessionId, class_id, fromdate, todate } = req.query;

      const assignments = await Assingment.findAllAssignment({
        sessionId,
        class_id,
        fromdate,
        todate
      });

      if (assignments && assignments.length > 0) {
        res.status(200).json(assignments);
      } else {
        res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ "success": false, "message": error.message });
    }
  });


  //   ----------------------- Delete Assignment -------------------
  router.delete("/:id", fetchUser, async (req, res) => {
    //Check permissions

   
    Assingment.init(req.userinfo.tenantcode);
    const result = await Assingment.deleteAssignment(req.params.id);
    if (!result)
      return res
        .status(200)
        .json({ success: false, message: "No record found" });

    res.status(200).json({ success: true, message: "Successfully Deleted" });
  });


  app.use(process.env.BASE_API_URL + "/api/assignment", router);
}