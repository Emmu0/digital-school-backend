/**
 * @author: Pawan Singh Sisodiya
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const feeInstallmentLineItem = require("../models/fee_installment_line_items.model.js");
const feeMasterLineItemsModel = require("../models/fee_master_installment.model.js");
const feeMasterModel = require("../models/fee_master.model.js");
//const permissions = require("../constants/permissions.js");

module.exports = app => {
    const { body, validationResult } = require('express-validator');
    var router = require("express").Router();
  
    //add record 
    router.post("/", fetchUser, [
   
      ],
  
      async (req, res) => {
        //Check permissions
        
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
          return res.status(400).json({ errors: errors.array() });
        }
  
        const body = req.body;
        const bodyStringify = JSON.stringify(body);
        const finalData = JSON.parse(bodyStringify);
        
        console.log("finalData--> ",finalData)
        const lineItemData = JSON.stringify(finalData.fee_head_master_id);
        const fee_master_id = finalData.fee_master_id;
        feeInstallmentLineItem.init(req.userinfo.tenantcode);
         const lineItems = await feeInstallmentLineItem.create(JSON.parse(lineItemData), fee_master_id, req.userinfo.id);
          if (lineItems.totalcount) {
          } else {
            return res.status(200).json({ "success": false, "message": "Bad Request" });
          }
      });

  //fetch All Records
  router.get("/", fetchUser, async (req, res) => {   
    
    feeInstallmentLineItem.init(req.userinfo.tenantcode);
    const result = await feeInstallmentLineItem.getAllRecords(); 
    if (result) {
      res.status(200).json(result);
    } else {
        res.status(200).json({ success: false, "message": "No Record Found!" });
     }
  });

  //fetch RecordById
  router.get("/:id", fetchUser, async (req, res) => {
    try {
      
      feeInstallmentLineItem.init(req.userinfo.tenantcode);
      let result = await feeInstallmentLineItem.getRecordByInstallmentId(req.params.id);
      console.log('result--->',result);
      if (result) {
        return res.status(200).json(result);
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ "success": false, "message": error });
    }
  });

  //fetch Fee_installment_line_items using classid and type
  router.get("/:admissionid/:sessionid", fetchUser, async (req, res) => {
    try {
      

      const admissionid = req.params.admissionid;
      const sessionid = req.params.sessionid;

      feeInstallmentLineItem.init(req.userinfo.tenantcode);
      let result = await feeInstallmentLineItem.getRecordByAdmissionIdAndSessionid(admissionid, sessionid);
      
      if (result) {
        return res.status(200).json({ "success": true, "data": result});
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ "success": false, "message": error });
    }
  });

  router.get("/classid/:classid/type/:type", fetchUser, async (req, res) => {
    try {
  
      feeInstallmentLineItem.init(req.userinfo.tenantcode);
      const result = await feeInstallmentLineItem.getInstallments(req?.params?.classid, req?.params?.type);
      console.log('result- feeInstallmentLineItem-->', result);
  
      if (result && result.length > 0) {
        return res.status(200).json(result);
      } else {
        return res.status(404).json({ "success": false, "message": "No records found" });
      }
    } catch (error) {
      console.error(error);
      return res.status(500).json({ "success": false, "message": "Internal server error" });
    }
  });

  router.put("/", fetchUser, async (req, res) => {
    try {
      
  
      const records = req.body;
      let results = [];
      let totalCategoryFee = {total_general_fees: 0, total_obc_fees: 0, total_sc_fees: 0, total_st_fees: 0}
      const feeMasterId = records[0].fee_master_id;
  
      for (const record of records) {
        let totalfees = { general_fee: 0, obc_fee: 0, sc_fee: 0, st_fee: 0 };
        let feeMasterInstallmentId = '';
        
        for (const item of record.fee_head_master_id) {
          const id = item.line_items_id;
          feeMasterInstallmentId = item.fee_master_installment_id;
  
          const updatedItem = {
            ...item,
            general_amount: item.general_fee,
            obc_amount: item.obc_fee,
            sc_amount: item.sc_fee,
            st_amount: item.st_fee
          };

          totalfees.general_fee += parseInt(item.general_fee);
          totalfees.obc_fee += parseInt(item.obc_fee);
          totalfees.sc_fee += parseInt(item.sc_fee);
          totalfees.st_fee += parseInt(item.st_fee);
  
          delete updatedItem.general_fee;
          delete updatedItem.obc_fee;
          delete updatedItem.sc_fee;
          delete updatedItem.st_fee;
          delete updatedItem.name;
          delete updatedItem.head_master_id;
          delete updatedItem.line_items_id;
          delete updatedItem.month;

          feeInstallmentLineItem.init(req.userinfo.tenantcode);
          let resultCon = await feeInstallmentLineItem.getRecordById(id);
  
          if (resultCon) {
            feeInstallmentLineItem.init(req.userinfo.tenantcode);
            resultCon = await feeInstallmentLineItem.updateRecordById(id, updatedItem, req.userinfo.id);
            console.log("resultCon", resultCon);
            results.push(resultCon);
          } else {
            return res.status(200).json({ "success": false, "message": "Record not found!" });
          }
        }
        console.log('totafees', totalfees);

        totalCategoryFee.total_general_fees +=  parseInt(totalfees.general_fee);
        totalCategoryFee.total_obc_fees +=  parseInt(totalfees.obc_fee);
        totalCategoryFee.total_sc_fees +=  parseInt(totalfees.sc_fee);
        totalCategoryFee.total_st_fees +=  parseInt(totalfees.st_fee);

        feeMasterLineItemsModel.init(req.userinfo.tenantcode);
        const resultMasterInstallment = await feeMasterLineItemsModel.updateRecordById(feeMasterInstallmentId, totalfees, req.userinfo.id);
        console.log('resultMasterInstallment-->', resultMasterInstallment);
        if(!resultMasterInstallment){
          return res.status(400).json({ "success": false, "message": "Failed to update master installment!!" });
        }
      }

      console.log('totalCategoryFee-->',totalCategoryFee);
      feeMasterModel.init(req.userinfo.tenantcode);
      const feeMasterResult = await feeMasterModel.updateRecordById(feeMasterId, totalCategoryFee, req.userinfo.id);
      console.log('feeMasterResult-->',feeMasterResult);

      if (results.length > 0) {
        return res.status(200).json({ "success": true, "message": "Records updated successfully", "data": results });
      } else {
        return res.status(400).json({ "success": false, "message": "Bad Request" });
      }
  
    } catch (error) {
      console.log("Errors =>", error);
      res.status(400).json({ errors: error.message });
    }
  });
  
  router.delete("/:id", fetchUser, async (req, res) => {  //Check permissions
    
    console.log("ID to be deleted:", req.params.id);
    feeInstallmentLineItem.init(req.userinfo.tenantcode);
    const result = await feeInstallmentLineItem.deleteFeeHead(req.params.id);//delete Record
    if (result) {
      res.status(200).json({ "success": true, "message": "Record Delete Successfully" });
    } else {
      return res.status(200).json({ "success": false, "message": "No Record found" });
    }
  });
  
  app.use('/api/feeinstallineitems', router);
};
