/**
 * @author: Pawan Singh Sisodiya
 */

const { createExamTitle, getExamTitles, updateExamTitleById, getExamTitleById, deleteExamTitle,
  createExamSchedule, getExamSchedules, updateExamScheduleById, getExamScheduleById, deleteExamSchedule, getRelatedRecords, init, getExamScheduleByClassId,
  duplicateExamTitleById } = require("../models/exam.model.js");
//const permissions = require("../constants/permissions.js");
const { fetchUser } = require("../middleware/fetchuser.js");

module.exports = (app) => {
  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  router.post("/examtitle", fetchUser,
    // [
    //   body("name").notEmpty().isString(),
    //   body("status").notEmpty().isString(), 
    //   body("sessionid").notEmpty().isString(),
    // ],
    async (req, res) => {
      // Check permissions


      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const examTitleData = req.body;
      console.log('@#examTitleData==>', examTitleData);
      const name = examTitleData.name;
      const sessionid = examTitleData.sessionid
      examTitleData.sessionid = examTitleData.sessionid === '' ? null : examTitleData.sessionid;
      init(req.userinfo.tenantcode);

      //Add by Aamir khan 29-04-2024
      const duplicate = await duplicateExamTitleById(name, sessionid);//check duplicate Record
      console.log('@#@duplicate==>', duplicate);
      if (duplicate) {
        console.log('I found duplacte Record', duplicate);
        return res.status(200).json({ "success": false, "message": "Record already exists." });
      } else {
        const examTitleResult = await createExamTitle(examTitleData);

        console.log('examTitleResult', examTitleResult);
        if (!examTitleResult) {
          return res.status(400).json({ error: "Bad Request" });
        }
        else {
          return res.status(201).json(examTitleResult);
        }

      }


    }
  );

  //   ---------------------Get Exam Titles------------------

  router.get("/examtitle", fetchUser, async (req, res) => {
    console.log('examgoon');
    //Check permissions

    init(req.userinfo.tenantcode);
    const examTitles = await getExamTitles();
    console.log('@examTitles==>', examTitles);
    if (examTitles) {
      res.status(200).json(examTitles);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });


  //   ----------------------- Update Exam Term -------------------

  router.put("/examtitle/:id", fetchUser,
    // [
    //     body("name").notEmpty().isString(),
    //     body("status").notEmpty().isString(), 
    //     body("sessionid").notEmpty().isString(), 
    // ],
    async (req, res) => {


      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const examTitleId = req.params.id;
      const examTitleData = req.body;
      examTitleData.sessionid = examTitleData.sessionid === '' ? null : examTitleData.sessionid;
      init(req.userinfo.tenantcode);
      const updatedExamTitle = await updateExamTitleById(examTitleId, examTitleData);

      if (!updatedExamTitle) {
        return res.status(404).json({ error: "Exam title not found" });
      }

      return res.status(200).json(updatedExamTitle);
    }
  );

  // ----------------------- Get Exam Title By Id -------------------
  router.get("/examtitle/:id", fetchUser, async (req, res) => {
    try {


      const examTitleId = req.params.id;
      init(req.userinfo.tenantcode);
      const examTitle = await getExamTitleById(examTitleId);

      if (examTitle) {
        return res.status(200).json(examTitle);
      } else {
        return res.status(404).json({ success: false, message: "No record found" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(400).json({ success: false, message: error });
    }
  });

  //   ---------------------- Delete Exam Title -----------------------
  router.delete("/examtitle/:id", fetchUser, async (req, res) => {
    try {


      const examTitleId = req.params.id;
      init(req.userinfo.tenantcode);
      const deleteResult = await deleteExamTitle(examTitleId);

      console.log('deleteResult===>', deleteResult);
      if (deleteResult && deleteResult.message) {
        return res.status(200).json({ success: true, message: deleteResult.message });
      } else if (deleteResult && deleteResult.error) {
        return res.status(400).json({ success: false, message: deleteResult.error });
      } else {
        return res.status(404).json({ success: false, message: "Exam title not found" });
      }
    } catch (error) {
      if (error.message === "Record has reference in another table. Deletion not allowed.") {
        return res.status(400).json({ success: false, message: "Record has reference in another table. Deletion not allowed." });
      } else {
        console.log("System Error===>:", error);
        return res.status(500).json({ success: false, message: "Internal Server Error" });
      }
    }
  });


  //   ----------------------------------------------------------------------
  //     ------------------- Routes For Exam Schedule ------------------
  //    ----------------------------------------------------------------------

  router.post(
    "/examschedule",
    fetchUser,
    // [
    //   body("exam_title_id").notEmpty().isString(), 
    //   body("schedule_date").notEmpty().isISO8601(),
    //   body("start_time").notEmpty().isString(),
    //   body("end_time").notEmpty().isString(),
    //   body("duration").notEmpty().isInt(),
    //   body("room_no").notEmpty().isString(),
    //   body("examinor_id").notEmpty().isString(), 
    //   body("status").notEmpty().isString(),
    //   body("subject_id").notEmpty().isString(), 
    //   body("class_id").notEmpty().isString(),   
    //   body("max_marks").notEmpty().isInt(),     
    //   body("min_marks").notEmpty().isInt(),     
    //   body("ispractical").notEmpty().isBoolean(),
    // ],
    async (req, res) => {


      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const examScheduleData = req.body;
      examScheduleData.max_marks = examScheduleData.max_marks ? parseInt(examScheduleData.max_marks) : null;
      examScheduleData.min_marks = examScheduleData.min_marks ? parseInt(examScheduleData.min_marks) : null;
      examScheduleData.duration = examScheduleData.duration ? parseInt(examScheduleData.duration) : null;
      examScheduleData.ispresent = examScheduleData.ispresent ? parseInt(examScheduleData.min_marks) : false;

      examScheduleData.examinor_id = examScheduleData.examinor_id === '' ? null : examScheduleData.examinor_id;

      init(req.userinfo.tenantcode);
      const examScheduleResult = await createExamSchedule(examScheduleData);

      console.log('examScheduleResult==>', examScheduleResult);
      if (!examScheduleResult) {
        return res.status(400).json({ error: "Bad Request" });
      }
      return res.status(201).json(examScheduleResult);
    }
  );

  //-------------------------- Get Exam Schedules ---------------------------

  router.get("/examschedule", fetchUser, async (req, res) => {

    init(req.userinfo.tenantcode);
    const examSchedules = await getExamSchedules();
    console.log('@#examSchedules==>', examSchedules);
    if (examSchedules) {
      res.status(200).json(examSchedules);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });

  //-------------------------- Get RelatedRecords ---------------------------

  router.get("/relatedrecords", fetchUser, async (req, res) => {

    init(req.userinfo.tenantcode);
    const relatedrecs = await getRelatedRecords();
    if (relatedrecs) {
      res.status(200).json(relatedrecs);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });

  // ----------------------------- Update Exam Schedule -----------------------------
  router.put(
    "/examschedule/:id",
    fetchUser,
    // [
    //   body("exam_title_id").notEmpty().isString(),
    //   body("schedule_date").notEmpty().isISO8601(),
    //   body("start_time").notEmpty().isString(),
    //   body("end_time").notEmpty().isString(),
    //   body("duration").notEmpty().isInt(),
    //   body("room_no").notEmpty().isString(),
    //   body("examinor_id").notEmpty().isString(),
    //   body("status").notEmpty().isString(),
    //   body("subject_id").notEmpty().isString(),
    //   body("class_id").notEmpty().isString(),
    //   body("max_marks").notEmpty().isInt(),
    //   body("min_marks").notEmpty().isInt(),
    //   body("ispractical").notEmpty().isBoolean(),
    // ],
    async (req, res) => {


      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const examScheduleId = req.params.id;
      const examScheduleData = req.body;
      examScheduleData.max_marks = examScheduleData.max_marks ? parseInt(examScheduleData.max_marks) : null;
      examScheduleData.min_marks = examScheduleData.min_marks ? parseInt(examScheduleData.min_marks) : null;
      examScheduleData.duration = examScheduleData.duration ? parseInt(examScheduleData.duration) : null;
      examScheduleData.ispresent = examScheduleData.ispresent ? parseInt(examScheduleData.min_marks) : false;
      examScheduleData.examinor_id = examScheduleData.examinor_id === '' ? null : examScheduleData.examinor_id;
      //examScheduleData.examinor_id = examScheduleData.examinor_id === false ? null : examScheduleData.examinor_id;
      init(req.userinfo.tenantcode);
      const updatedExamSchedule = await updateExamScheduleById(
        examScheduleId,
        examScheduleData
      );

      if (!updatedExamSchedule) {
        return res.status(404).json({ error: "Exam schedule not found" });
      }

      return res.status(200).json(updatedExamSchedule);
    }
  );

  // ---------------------------- Get Exam Schedule By Id --------------------------
  router.get("/examschedule/:id", fetchUser, async (req, res) => {
    try {


      const examScheduleId = req.params.id;
      init(req.userinfo.tenantcode);
      const examSchedule = await getExamScheduleById(examScheduleId);

      if (examSchedule) {
        return res.status(200).json(examSchedule);
      } else {
        return res.status(404).json({ success: false, message: "No record found" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(400).json({ success: false, message: error });
    }
  });

  // ------------------------- GET EXAM SCHEDULE BY CLASS ID AND STUDENT ADMISSION ID --------------------------

  router.get("/examschedule/class/:classid/:admissionid", fetchUser, async (req, res) => {
    try {


      const classId = req.params.classid;
      const admissionId = req.params.admissionid;

      init(req.userinfo.tenantcode);
      const examSchedule = await getExamScheduleByClassId(classId, admissionId);

      if (examSchedule) {
        return res.status(200).json(examSchedule);
      } else {
        return res.status(404).json({ success: false, message: "No record found" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(400).json({ success: false, message: error });
    }
  });
  // -------------------------------- Delete Exam Schedule ------------------------------
  router.delete("/examschedule/:id", fetchUser, async (req, res) => {
    try {


      const examScheduleId = req.params.id;
      init(req.userinfo.tenantcode);
      const deleteResult = await deleteExamSchedule(examScheduleId);

      if (deleteResult) {
        return res.status(200).json({ success: true, message: "Exam Schedule deleted successfully" });
      } else {
        return res.status(404).json({ success: false, message: "Exam Schedule not found" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(400).json({ success: false, message: error });
    }
  });



  app.use(process.env.BASE_API_URL + "/api/exams", router);
};
