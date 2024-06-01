/**
 * @author: Pawan Singh Sisodiya
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const feeMasterModel = require("../models/fee_master.model.js");
//const permissions = require("../constants/permissions.js");
const feeInstallmentLineItem = require("../models/fee_installment_line_items.model.js");
const feeMasterInstallment = require("../models/fee_master_installment.model.js");

module.exports = app => {
  const { body, validationResult } = require('express-validator');
  var router = require("express").Router();

  router.post("/", fetchUser, [
  ],
    async (req, res) => {
      
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      const body = req.body;
      const bodyStringify = JSON.stringify(body);
      const finalData = JSON.parse(bodyStringify);
      const dummylineItm = finalData.map((res) => res.fee_head_master_id);
      const stringifyLineItm = JSON.stringify(dummylineItm);

      feeMasterModel.init(req.userinfo.tenantcode);
      const isDuplicateRecords = await feeMasterModel.duplicateRecord(finalData);
      if(isDuplicateRecords?.length){
        return res.status(409).json({ "success": false, "message": "Duplicate records are not allowed!!" });
      }

      feeMasterModel.init(req.userinfo.tenantcode);
      const result = await feeMasterModel.create(finalData, req.userinfo.id);
      if (result) {
        res.status(200).json({ "success": true, "result": result });

        feeMasterInstallment.init(req.userinfo.tenantcode);
        const installmentResult = await feeMasterInstallment.create(JSON.parse(JSON.stringify(req.body)), result.id, req.userinfo.id)
        if (installmentResult) {
          feeInstallmentLineItem.init(req.userinfo.tenantcode);
          const lineItems = await feeInstallmentLineItem.create(req.body, installmentResult, req.userinfo.id, req.userinfo.tenantcode);
          if (lineItems) {
            return res.status(200).json({ "success": true, "result": result, "installmentResult": installmentResult, "lineItems": lineItems });
          }
        }

      } else {
        return res.status(200).json({ "success": false, "message": "Bad Request" });
      }
    });


  //fetch All Records
  router.get("/:id?", fetchUser, async (req, res) => {
    
    feeMasterModel.init(req.userinfo.tenantcode);
    const result = await feeMasterModel.getAllRecords(req?.params?.id);
    if (result) {
      res.status(200).json(result);
    } else {
      res.status(200).json({ success: false, "message": "No Record Found!" });
    }
  });

  //fetch All Active Records
  router.get("/active", fetchUser, async (req, res) => {
    //Check permissions
    
    feeMasterModel.init(req.userinfo.tenantcode);
    const result = await feeMasterModel.getAllRecordActiveRecs(); 
    if (result) {
      res.status(200).json(result);
    } else {
      res.status(200).json({ errors: "No Record found!" });
    }
  });

  //fetch RecordById
  // router.get("/:id", fetchUser, async (req, res) => {  
  //   try {
  
  //     feeMasterModel.init(req.userinfo.tenantcode);
  //     let result = await feeMasterModel.getRecordById(req.params.id);
  //     if (result) {
  //       return res.status(200).json(result);
  //     } else {
  //       return res.status(200).json({ "success": false, "message": "No record found" });
  //     }
  //   } catch (error) {
  //     return res.status(400).json({ "success": false, "message": error });
  //   }
  // });


  router.get("/feetype/:id", fetchUser, async (req, res) => {
    try {
      console.log('feetype getting-->');
  
      feeMasterModel.init(req.userinfo.tenantcode);
      const installmentResult = await feeMasterModel.feetypeInstallments(req?.params?.id);
      console.log('installmentResult-->', installmentResult);
  
      if (installmentResult) {
        return res.status(200).json({ success: true, installments: installmentResult });
      } else {
        return res.status(404).json({ success: false, message: "No record found" });
      }
    } catch (error) {
      console.error('Error in endpoint', error);
      return res.status(400).json({ success: false, message: error.message });
    }
  });

  //update record
  router.put("/:id", fetchUser, async (req, res) => {
    try {
      
      const errors = [];

      if (errors.length !== 0) {
        return res.status(400).json({ errors: errors });
      }

      feeMasterModel.init(req.userinfo.tenantcode);
      let resultCon = await feeMasterModel.getRecordById(req.params.id);
      if (resultCon) {
        result = await feeMasterModel.updateRecordById(req.params.id, req.body.feeMaster, req.userinfo.id);
        console.log("result", result)
        if (result) {
          return res.status(200).json({ "success": true, "message": "Record updated successfully" });
        } else {
          return res.status(200).json({ "success": false, "message": "Bad Request" });
        }
      } else {
        return res.status(200).json({ "success": false, "message": "No record found !!" });
      }

    } catch (error) {
      res.status(400).json({ errors: error });
    }

  });

  //delete Record
  router.delete("/:id", fetchUser, async (req, res) => {  //Check permissions
    
    feeMasterModel.init(req.userinfo.tenantcode);
    const result = await feeMasterModel.deleteFeeHead(req.params.id);//delete Record
    if (result) {
      res.status(200).json({ "success": true, "message": "Record Delete Successfully" });
    } else {
      return res.status(200).json({ "success": false, "message": "No Record found" });
    }
  });

  app.use( '/api/feemasters', router);
};