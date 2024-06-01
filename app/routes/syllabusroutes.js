/**
 * @author : Shakib Khan
 */
const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const Syllabus = require("../models/syllabusmodel.js");
//const permissions = require("../constants/permissions.js");

module.exports = app => {

  const { body, validationResult } = require("express-validator");
  var router = require("express").Router();

  router.post("/", fetchUser, [],
    async (req, res) => {
      try {

        const errors = validationResult(req);
        if (!errors.isEmpty()) {
          return res.status(400).json({ errors: errors.array() });
        }

        console.log("syllabus route req.body => ", req.body);
        Syllabus.init(req.userinfo.tenantcode);
        // Assuming CreateSyllabus method returns a Promise
        console.log('asfvs');
        const syllabusRecord = await Syllabus.CreateSyllabus(req.body);

        if (!syllabusRecord) {
          return res.status(200).json({ message: 'This record already exists' });
        }

        return res.status(201).json(syllabusRecord);
      } catch (error) {
        console.error('Error processing the request:', error);
        return res.status(500).json({ errors: 'Internal Server Error' });
      }
    }
  );

  //   ----------------------- Get All Syllabus -------------------

  router.get("/getallsyllabus", fetchUser, async (req, res) => {

    Syllabus.init(req.userinfo.tenantcode);
    const syllabus = await Syllabus.findAllSyllabus();
    console.log('syllabus============>', syllabus);
    if (syllabus) {
      res.status(200).json(syllabus);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });

  //------------------------- Update Syllabus ---------------------

  router.put("/:id", fetchUser, [], async (req, res) => {

    const errors = validationResult(req);

    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    const syllabusId = req.params.id;
    const syllabusData = req.body;
    Syllabus.init(req.userinfo.tenantcode);
    const updateSyllabus = await Syllabus.updateSyllabusById(syllabusId, syllabusData);
    if (!updateSyllabus) {
      return res.status(201).json({ message: "This record already exists" });
    }
    return res.status(200).json(updateSyllabus);
  }
  );

  //   ----------------------- Delete Syllabus -------------------
  router.delete("/:id", fetchUser, async (req, res) => {
  
    Syllabus.init(req.userinfo.tenantcode);
    const result = await Syllabus.deleteSyllabus(req.params.id);
    if (!result)
      return res
        .status(200)
        .json({ success: false, message: "No record found" });

    res.status(200).json({ success: true, message: "Successfully Deleted" });
  });

  app.use(process.env.BASE_API_URL + "/api/syllabus", router);
}