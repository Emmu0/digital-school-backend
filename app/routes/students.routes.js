/**
 * Handles all incoming request for /api/Students endpoint
 * DB table for this public.Student
 * Model used here is Student.model.js
 * SUPPORTED API ENDPOINTS
 *              GET     /api/Students
 *              GET     /api/Students/:id
 *              POST    /api/Students
 *              PUT     /api/Students/:id
 *              DELETE  /api/Students/:id
 *
 * @author      Ronak Sharma
 * @date        01 Aug 2023
 * @copyright   www.ibirdsservices.com
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Student = require("../models/student.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = (app) => {
  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  // ................................ Create a new Student ................................
  router.post("/", fetchUser, [
  ],

    async (req, res) => {

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      Student.init(req.userinfo.tenantcode);
      const StudentRec = await Student.createStudent(req.body, req.userinfo.id);
      if (StudentRec != null) {
        //return res.status(200).json({ "success": false, "result": StudentRec });
        return res.status(200).json({ "success": true, "message": "Successfully Created Record", "result": StudentRec });//pawan code
      } else {
        return res.status(400).json({ errors: "Bad Request" });
      }
    }
  );

  router.post("/dupli/", fetchUser, [
  ],
    async (req, res) => {

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      Student.init(req.userinfo.tenantcode);
      let duplicate = await Student.duplicateRecord(null, req.body);//check duplicate Record
      if (duplicate) {
        return res.status(200).json({ "success": false, "message": "Record already exists." });
      } else {
        return res.status(200).json({ "success": false, "message": null });
      }
      return null;
    }
  );
  // .....................................Get Student by Id........................................
  // .....................................Get Student by Id........................................
  router.get("/sibling/:id", fetchUser, async (req, res) => {
    try {

      Student.init(req.userinfo.tenantcode);
      let StudentRec = await Student.findByStudentId(req.params.id);
      if (StudentRec) {
        return res.status(200).json(StudentRec);
      } else {
        return res
          .status(200)
          .json({ success: false, message: "No record found" });
      }
    } catch (error) {
      console.log('erroree=>',error)
      return res.status(400).json({ success: false, message: error });
    }
  });
  router.get("/rte/:id", fetchUser, async (req, res) => {
    try {

      Student.init(req.userinfo.tenantcode);
      let StudentRec = await Student.findByStudentRteId(req.params.id);
      if (StudentRec) {
        return res.status(200).json(StudentRec);
      } else {
        return res
          .status(200)
          .json({ success: false, message: "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ success: false, message: error });
    }
  });
  // .....................................Get student by class id........................................
  router.get("/class/:id", fetchUser, async (req, res) => {
    try {

      Student.init(req.userinfo.tenantcode);
      let StudentRec = await Student.fetchStudentByClassId(req.params.id);
      if (StudentRec) {
        return res.status(200).json(StudentRec);
      } else {
        return res
          .status(200)
          .json({ success: false, message: "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ success: false, message: error });
    }
  });
  // .....................................Get student by class id........................................
  router.get("/addmission/class/:id", fetchUser, async (req, res) => {
    try {

      Student.init(req.userinfo.tenantcode);
      let StudentRec = await Student.fetchStudentAddmissionByClassId(req.params.id);
      if (StudentRec) {
        return res.status(200).json(StudentRec);
      } else {
        return res
          .status(200)
          .json({ success: false, message: "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ success: false, message: error });
    }
  });
  // .....................................Get student by parent id........................................
  router.get("/parent/:id", fetchUser, async (req, res) => {
    try {

      Student.init(req.userinfo.tenantcode);
      let StudentRec = await Student.fetchStudentByParentId(req.params.id);
      if (StudentRec) {
        return res.status(200).json(StudentRec);
      } else {
        return res
          .status(200)
          .json({ success: false, message: "No record found" });
      }
    } catch (error) {
      console.log("error student", error)
      return res.status(400).json({ success: false, message: error });
    }
  });
  //..............................Added by Shakib : Get All RTE Students.............................

  router.get("/getrte", fetchUser, async (req, res) => {

    Student.init(req.userinfo.tenantcode);
    const getRteStudent = await Student.getRteStudents();
    if (getRteStudent) {
      res.status(200).json(getRteStudent);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  })

  // .....................................Get All Students...................................
  router.get("/", fetchUser, async (req, res) => {

    Student.init(req.userinfo.tenantcode);
    const Students = await Student.findAllStudents();
    if (Students) {
      res.status(200).json(Students);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });
  router.get("/:id?", fetchUser, async (req, res) => {
    try {

      const sectionId = req.query.section_id;
      const sessionId = req.query.session_id;
      console.log('req.params.id@@@=>', req.params.id)
      Student.init(req.userinfo.tenantcode);
      let studentRecords = await Student.getAllRecords(req.params.id, sectionId, sessionId);
      console.log('studentRecords@####', studentRecords)
      if (studentRecords) {
        return res.status(200).json({ success: true, "records": studentRecords });
      } else {
        res.status(200).json({ success: false, "message": "No Record Found!" });
      }
    } catch (error) {
      return res.status(200).json({ success: false, message: error });
    }
  });
  // .....................................Get Student by Id...................................
  router.get("/:id", fetchUser, async (req, res) => {
    try {


      Student.init(req.userinfo.tenantcode);
      let StudentRec = await Student.findByStudentId(req.params.id);
      if (StudentRec) {
        return res.status(200).json(StudentRec);
      } else {
        return res
          .status(200)
          .json({ success: false, message: "No record found" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(400).json({ success: false, message: error });
    }
  });

  // .....................................Get Student by schema.user.id Id...................................
  router.get("/schemauser/:id", fetchUser, async (req, res) => {
    try {


      Student.init(req.userinfo.tenantcode);
      let StudentRec = await Student.findBySchemaUserId(req.params.id);
      if (StudentRec) {
        return res.status(200).json(StudentRec);
      } else {
        return res
          .status(200)
          .json({ success: false, message: "No record found" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(400).json({ success: false, message: error });
    }
  });

  // .....................................Get Student by SR Number................................
  router.get("/srnumber/:srno", fetchUser, async (req, res) => {
    try {

      Student.init(req.userinfo.tenantcode);
      let StudentRec = await Student.findBySRNumber(req.params.srno);
      if (StudentRec) {
        return res.status(200).json(StudentRec);
      } else {
        return res
          .status(200)
          .json({ success: false, message: "No record found" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(400).json({ success: false, message: error });
    }
  });

  //......................................Update Student......................................
  router.put("/:id", fetchUser, async (req, res) => {
    try {



      const errors = [];
      const studentRec = {};
      const filedsToIgnore = ['lastmodifieddate', 'createddate', 'createdbyid', 'lastmodifiedbyid', 'createdbyname', 'lastmodifiedbyname', 'studentname'];

      for (const field in req.body) {
        if (req.body.hasOwnProperty(field) && !filedsToIgnore.includes(field)) {
          studentRec[field] = req.body[field];
        }
      }

      console.log('req.params.id => ', req.params.id);
      Student.init(req.userinfo.tenantcode);
      let studentResult = await Student.findByStudentId(req.params.id);
      if (studentResult) {
        console.log("studentResult => ", studentResult);
        studentResult = await Student.updateById(req.params.id, studentRec, req.userinfo.id);
        if (studentResult) {
          console.log("studentResult after update => ", studentResult);
          return res.status(200).json({ success: true, message: "Record updated successfully" });
        }
        return res.status(200).json(studentResult);
      }
      /* else {
       return res .status(200) .json({ success: false, message: "No record found" });
     } */
    } catch (error) {
      res.status(400).json({ errors: error });
    }
  });

  // Delete a Tutorial with id
  router.delete("/:id", fetchUser, async (req, res) => {

    Student.init(req.userinfo.tenantcode);
    const result = await Student.deleteStudent(req.params.id);
    if (!result) {
      return res.status(200).json({ success: false, message: "No record found" });
    }
    res.status(200).json({ success: true, message: "Successfully Deleted" });
  });

  app.use(process.env.BASE_API_URL + "/api/students", router);
  //app.use( "/api/students", router);
};
