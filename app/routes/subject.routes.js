/**
 * @author : Abdul Pathan
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const subjectRecord = require("../models/subject.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = app => {
  const { body, validationResult } = require('express-validator');
  var router = require("express").Router();

  //add record 
  router.post("/", fetchUser, [
    body('name', 'Please enter Subject Name').isLength({ min: 1 }),
  ],

    async (req, res) => {

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      subjectRecord.init(req.userinfo.tenantcode);
      let duplicate = await subjectRecord.duplicateRecord(null, req.body);

      if (!duplicate) {
        const result = await subjectRecord.addRecord(req.body, req.userinfo.id);
        if (result) {
          return res.status(200).json({ "success": true, "result": result });
        } else {
          return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
      } else {
        return res.status(200).json({ "success": false, "message": "Record already exists." });
      }
    });

  //Add by Aamir khan 14-05-2024
  router.get("/active", fetchUser, async (req, res) => {
    try {


      subjectRecord.init(req.userinfo.tenantcode);


      const result = await subjectRecord.fetchActiveRecords();
      if (result) {
        res.status(200).json(result);
      } else {
        res.status(400).json({ errors: "No data" });
      }


    } catch (error) {

      console.error('NewError fetching active subjects:', error);
      res.status(500).json({ error: 'Internal server error' });
    }


  });






  //fetch all record

  // ==================  Add By Aamir khan  Code Start ==========================

  //Add by Aamir khan
  router.get("/:search?/:status?/:type?", fetchUser, async (req, res) => {

    subjectRecord.init(req.userinfo.tenantcode);

    console.log('req.params.type==>', req.params.type);
    console.log('Colling this time1');
    console.log('Helloreq.body Data==>1', req.body);
    const result = await subjectRecord.fetchAllRecords(req?.params?.status != undefined ? req?.params?.status : null, req?.params?.type != undefined ? req?.params?.type : null);
    if (result) {
      res.status(200).json(result);
    } else {
      res.status(400).json({ errors: "No data" });
    }

  });



  router.get("/:id", fetchUser, async (req, res) => {
    try {


      subjectRecord.init(req.userinfo.tenantcode);

      let result = await subjectRecord.fetchRecordById(req.params.id);
      if (result) {
        return res.status(200).json(result);
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ "success": false, "message": error });
    }
  });




  //update record
  router.put("/:id", fetchUser, async (req, res) => {
    try {

      subjectRecord.init(req.userinfo.tenantcode);
      let resultCon = await subjectRecord.fetchRecordById(req?.params?.id);
      //console.log('justnow stap',resultCon);
      if (resultCon) {
        //  console.log('True');
        subjectRecord.init(req.userinfo.tenantcode);
        let duplicate = await subjectRecord.duplicateRecord(req.params.id, req.body);

        if (!duplicate) {
          // console.log('req.body',req.body);
          subjectRecord.init(req.userinfo.tenantcode);
          resultCon = await subjectRecord.updateRecordById(req.params.id, req.body, req.userinfo.id);
          //console.log('Stap2');
          if (resultCon) {
            return res.status(200).json({ "success": true, "message": "Record updated successfully" });
          } else {
            //console.log('Bad Req');
            return res.status(200).json({ "success": false, "message": "Bad Request" });
          }
        } else {
          // console.log('recordaleradyexit');
          return res.status(200).json({ "success": false, "message": "Record already exists." });
        }

      } else {
        // console.log('norecordfound')
        return res.status(200).json({ "success": false, "message": "No record found" });
      }

    } catch (error) {
      // console.log('@#Error',error);
      res.status(400).json({ errors: error });
    }

  });

  //delete record by id
  router.delete("/:id", fetchUser, async (req, res) => {

    subjectRecord.init(req.userinfo.tenantcode);
    const result = await subjectRecord.deleteRecord(req.params.id);

    if (!result)
      return res.status(200).json(
        {
          "success": false,
          "message": "This Record has refrence in another table."
        });

    res.status(200).json(
      {
        "success": true,
        "message": "Successfully Deleted"
      });
  });

  app.use(process.env.BASE_API_URL + '/api/subjects', router);
};

