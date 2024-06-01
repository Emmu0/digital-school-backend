/**
 * @author: Abdul Pathan
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const classModel = require("../models/class.model.js");
const sectionModel = require("../models/section.model.js")


module.exports = app => {
  const { body, validationResult } = require('express-validator');
  var router = require("express").Router();


  //Fetch all records
  //Create this route by Shahir Hussain 10-05-2024
  router.get("/:?", fetchUser, async (req, res) => {

    classModel.init(req.userinfo.tenantcode);
    const result = await classModel.getAllRecords(req.query.className); //fetch Records
    sectionModel.init(req.userinfo.tenantcode);
    const sections = await sectionModel.getAllRecords();
    console.log('Sections == ', sections)
    console.log('class result == ', result);

    const fullData = result.map(item => {
      let section = [],

        data = {
          class_id: item.id, classname: item.class_name, status: item.status,
          aliasname: item.aliasname, section: {}
        }
      let sortedItems = [];
      sections.map(sec => {
        if (item.id === sec.class_id && sec.isactive === true) {
          section.push({ section_name: sec.section_name, section_id: sec.section_id })
        }

      }),
        sortedItems = section.slice().sort((a, b) => {
          console.log('a = ', a.section_name, ' and ', 'b = ', b.section_name);
          if (a.section_name < b.section_name) {
            return -1;
          }
          return 0;
        });
      data.section = sortedItems
      console.log('full data == ', data);
      return data;
    });
    fullData.map(items => {
      console.log('data == ', items.classname);
    })
    console.log('full All data == ', fullData);

    if (fullData) {
      res.status(200).json(fullData);
    } else {
      res.status(200).json({ errors: "No Record found!" });
    }
  });

  //fetch All Active Records
  router.get("/active", fetchUser, async (req, res) => {

    classModel.init(req.userinfo.tenantcode);
    const result = await classModel.getAllRecordActiveRecs(); //fetch Records
    if (result) {
      res.status(200).json(result);
    } else {
      res.status(200).json({ errors: "No Record found!" });
    }
  });
  //fetch RecordById
  router.get("/:id", fetchUser, async (req, res) => {    //Check permissions

    try {

      classModel.init(req.userinfo.tenantcode);
      let result = await classModel.getRecordById(req.params.id);//fetch Record By Id
      if (result) {
        return res.status(200).json(result);
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ "success": false, "message": error });
    }
  });


  //add Record
  router.post("/add", fetchUser, [
    body('classname', 'Please enter class Name').isLength({ min: 1 }),
    // body('aliasname', 'Please enter Name').isLength({ min: 1 }),
    // body('status', 'Please enter status').isLength({ min: 1 }),
  ],

    async (req, res) => {
      // const errors = validationResult(req);

      // if (!errors.isEmpty()) {
      //   return res.status(400).json({ errors: errors.array() });
      // }
      classModel.init(req.userinfo.tenantcode);
      let duplicate = await classModel.duplicateRecord(null, req.body);//check duplicate Record
      if (!duplicate) {

        const result = await classModel.addRecord(req.body, req.userinfo.id);//add Record
        if (result) {
          return res.status(200).json({ "success": true, 'record': result });
        }
        else {
          return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
      }
      else {
        return res.status(200).json({ "success": false, "message": "Record already exists." });
      }
    });

  //update Record
  router.put("/:id", fetchUser, async (req, res) => {//Check permissions
    try {

      const { classname, aliasname, status, session_year } = req.body;
      console.log('classname, aliasname, status, session_year======>', classname, aliasname, status, session_year);
      const errors = [];
      const classRecord = {};

      if (req.body.hasOwnProperty("classname")) { classRecord.classname = classname };
      if (req.body.hasOwnProperty("aliasname")) { classRecord.aliasname = aliasname };
      if (req.body.hasOwnProperty("status")) { classRecord.status = status };
      // if (req.body.hasOwnProperty("session_year")) { classRecord.session_year = session_year };

      if (errors.length !== 0) {
        return res.status(400).json({ errors: errors });
      }
      classModel.init(req.userinfo.tenantcode);
      let result = await classModel.getRecordById(req.params.id);

      if (result) {
        let duplicate = await classModel.duplicateRecord(req.params.id, classRecord);//duplicate Record check

        if (!duplicate) {
          let responce = await classModel.updateRecordById(req.params.id, classRecord, req.userinfo.id);
          if (responce) {
            return res.status(200).json({ "success": true, "record": responce });
          } else {
            return res.status(200).json({ "success": false, "message": "Bad Request" });
          }
        } else {
          return res.status(200).json({ "success": false, "message": "Record already exists." });
        }
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(200).json({ "success": false, "message": "Bad Request" });
    }
  });



  //delete Record
  router.delete("/:id", fetchUser, async (req, res) => {  //Check permissions

    classModel.init(req.userinfo.tenantcode);
    const result = await classModel.deleteRecord(req.params.id);//delete Record
    if (result) {
      res.status(200).json({ "success": true, "message": "Record Delete Successfully" });
    } else {
      return res.status(200).json({ "success": false, "message": "No Record found" });
    }
  });

  app.use(process.env.BASE_API_URL + '/api/classes', router);
};