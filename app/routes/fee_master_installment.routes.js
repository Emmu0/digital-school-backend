/**
 * @author: Pawan Singh Sisodiya
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const feeMasterLineItemsModel = require("../models/fee_master_installment.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = app => {
    const { body, validationResult } = require('express-validator');
    var router = require("express").Router();
  
    //add record 
    router.post("/", fetchUser,
      async (req, res) => {
        //Check permissions
        
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
          return res.status(400).json({ errors: errors.array() });
        }

        console.log('line item is about to create', req.body);
        feeMasterLineItemsModel.init(req.userinfo.tenantcode);
        let duplicate = await feeMasterLineItemsModel.duplicateRecord(null, req.body);
  
        if (!duplicate) {
           feeMasterLineItemsModel.init(req.userinfo.tenantcode);
          const result = await feeMasterLineItemsModel.create(req.body, req.userinfo.id);
          console.log('result',result);
          if (result) {
            return res.status(200).json({ "success": true, "result": result });
          } else {
            return res.status(200).json({ "success": false, "message": "Bad Request" });
          }
        } else {
          return res.status(200).json({ "success": false, "message": "Record is already exist!" });
        }
      });


  //fetch All Records
  router.get("/:?", fetchUser, async (req, res) => { 
    console.log('fetch all class rec')   //Check permissions
    
    feeMasterLineItemsModel.init(req.userinfo.tenantcode);
    const result = await feeMasterLineItemsModel.getAllRecords(); //fetch Records
    if (result) {
      res.status(200).json(result);
    } else {
      res.status(400).json({ errors: "No Record found!" });
    }
  });


  //fetch RecordById
  router.get("/get/:id", fetchUser, async (req, res) => {  
    try {
      

      feeMasterLineItemsModel.init(req.userinfo.tenantcode);
      console.log('req.params.id',req.params.id);
      let result = await feeMasterLineItemsModel.getRecordById(req.params.id);
      console.log('result',result);
      if (result) {
        return res.status(200).json(result);
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ "success": false, "message": error });
    }
  });

  router.put("/:id", fetchUser, async (req, res) => {
    try {
      //Check permissions
      console.log('inside update routes-->', req.body);
      

      const errors = [];
      if (errors.length !== 0) {
        return res.status(400).json({ errors: errors });
      }

      feeMasterLineItemsModel.init(req.userinfo.tenantcode);
      let resultCon = await feeMasterLineItemsModel.getRecordDuringUpdate(req.params.id);
      if (resultCon) {

        resultCon = await feeMasterLineItemsModel.updateRecordById(req.params.id, req.body, req.userinfo.id);
        console.log("resultCon", resultCon)
        if (resultCon) {
          return res.status(200).json({ "success": true, "message": "Record updated successfully" });
        } else {
          return res.status(200).json({ "success": false, "message": "Bad Request" });
        }


      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }

    } catch (error) {
      console.log("Errors =>", error)
      res.status(400).json({ errors: error });
    }

  });
  //delete Record
  router.delete("/:id", fetchUser, async (req, res) => {  //Check permissions
    
    feeMasterLineItemsModel.init(req.userinfo.tenantcode);
    const result = await feeMasterLineItemsModel.deleteFeeHead(req.params.id);//delete Record
    if (result) {
      res.status(200).json({ "success": true, "message": "Record Delete Successfully" });
    } else {
      return res.status(200).json({ "success": false, "message": "No Record found" });
    }
  });

  app.use( '/api/feemasterline', router);
};