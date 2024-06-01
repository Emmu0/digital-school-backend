/**
 * @author: Pawan Singh Sisodiya
 */

const express = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const feeDepositeModel = require("../models/fee_deposite.model.js");
//const permissions = require("../constants/permissions.js");
const student_fee_installments = require("../models/student_fee_installments.model.js");

module.exports = (app) => {
  const { body, validationResult } = require("express-validator");
  const router = express.Router();

  // Create (Add) Record
  router.post("/", fetchUser, [], async (req, res) => {
    try {

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      console.log("req.body-->", req.body);

      const record = {
        student_addmission_id: req?.body?.student_addmission_id,
        amount: req?.body?.amount,
        payment_date: req?.body?.payment_date,
        payment_method: req?.body?.payment_method,
        late_fee: req?.body?.late_fee,
        remark: req?.body?.remark,
        discount: req?.body?.discount,
        sessionid: req?.body?.sessionid,
      };
      feeDepositeModel.init(req.userinfo.tenantcode);
      const result = await feeDepositeModel.createFeeDeposite(
        record,
        req.userinfo.id
      );

      console.log("checked months has created -->", result);

      let success = true;
      let results = [];

      if (result) {
        const dueAmountRecord = {
          student_addmission_id: req?.body?.student_addmission_id,
          dues: Math.round(req?.body?.due_amount ? req?.body?.due_amount : 0),
          session_id: req?.body?.sessionid,
        };

        // console.log('new code updated');
        // Check if due amount record already exists
        feeDepositeModel.init(req.userinfo.tenantcode);
        let existingDueAmountRecord =
          await feeDepositeModel.duplicatePendingAmount(
            dueAmountRecord.student_addmission_id
          );

        let dueAmountResult = null;
        let isStudentLastInstallment = false;

        if (existingDueAmountRecord) {
          console.log(
            req.userinfo.tenantcode,
            existingDueAmountRecord,
            "existingDueAmountRecord ==>"
          );
          feeDepositeModel.init(req.userinfo.tenantcode);
          dueAmountResult =
            await feeDepositeModel.updatePendingAmountRecordById(
              existingDueAmountRecord[0].id,
              dueAmountRecord,
              req.userinfo.id
            );
          if (!dueAmountResult) {
            res.status(400).json({
              success: false,
              message: "Error while updating pending amount",
            });
          }
        } else {
          feeDepositeModel.init(req.userinfo.tenantcode);
          dueAmountResult = await feeDepositeModel.createDueAmount(
            dueAmountRecord,
            req.userinfo.id
          );
          if (!dueAmountResult) {
            res.status(400).json({
              success: false,
              message: "Error while creating pending amount",
            });
          }
        }

        student_fee_installments.init(req.userinfo.tenantcode);
        const allStudentFeeInstallments =
          await student_fee_installments.fetchRecordById(
            req?.body?.student_addmission_id
          );
        console.log("allStudentFeeInstallments-->", allStudentFeeInstallments);

        let lastSelectedInstallment = allStudentFeeInstallments.filter((res) => res.id === req?.body?.installments[req?.body?.installments.length - 1].id);


        console.log('lastSelectedInstallment-->', lastSelectedInstallment);
        let nextorderno = parseInt(lastSelectedInstallment[0]?.orderno) + 1;
        console.log("nextorderno-->", nextorderno);

        let allCheckedInstallments = req?.body?.installments;

        let recordsToBeUpdated = allStudentFeeInstallments
          .filter(res => allCheckedInstallments.some(inst => res.id === inst.id))
          .map(itm => ({ ...itm, status: 'completed', previous_due: 0 }));

        let recordForPendingAmountUpdated = allStudentFeeInstallments.filter((res) => {
          if (parseInt(res.orderno) === parseInt(nextorderno)) {
            return res;
          }
        });

        recordsToBeUpdated.map((res) => {
          if (res.id === lastSelectedInstallment[0].id) {
            res.deposit_id = result.id;
            // res.deposit_amount = result.amount;
          }
        })

        if (recordForPendingAmountUpdated[0]?.id) {
          recordsToBeUpdated.push({ id: recordForPendingAmountUpdated[0]?.id, previous_due: req?.body?.due_amount })
        }

        console.log('recordsToBeUpdated-->', recordsToBeUpdated);
        console.log('recordForPendingAmountUpdated-->', recordForPendingAmountUpdated);

        console.log("recordsToBeUpdated-->", recordsToBeUpdated);
        console.log(
          "recordForPendingAmountUpdated-->",
          recordForPendingAmountUpdated
        );

        for (let i = 0; i < recordsToBeUpdated?.length; i++) {
          const student_fee_installment_id = recordsToBeUpdated[i].id;
          delete recordsToBeUpdated[i].id;
          student_fee_installments.init(req.userinfo.tenantcode);
          const updatedResult = await student_fee_installments.updateRecordById(
            student_fee_installment_id,
            recordsToBeUpdated[i],
            req.userinfo.id,
            req.userinfo.tenantcode
          );

          results.push(updatedResult);
          if (!updatedResult) {
            success = false;
            break;
          }
        }

        if (success) {
          res.status(200).json({
            success: true,
            deposit: result,
            student_installments: results,
          });
        } else {
          res.status(400).json({ success: false, message: "Updated Failed" });
        }
      } else {
        res.status(400).json({ success: false, message: "Bad Request" });
      }
    } catch (err) {
      console.error("Error:", err);
      res
        .status(500)
        .json({ success: false, message: "Internal Server Error" });
    }
  });

  // Read (Fetch) All Records
  router.get("/", fetchUser, async (req, res) => {


    // Initialize model and fetch all records
    feeDepositeModel.init(req.userinfo.tenantcode);
    const result = await feeDepositeModel.getAllFeeDeposits();

    if (result.length > 0) {
      res.status(200).json(result);
    } else {
      res.status(200).json({ success: false, message: "No Record Found!" });
    }
  });

  // Read (Fetch) Record by ID
  router.get("/:id", fetchUser, async (req, res) => {


    // Initialize model and fetch record by ID
    feeDepositeModel.init(req.userinfo.tenantcode);
    console.log("req.params.id-->", req.params.id);
    const result = await feeDepositeModel.getFeeDepositeById(req.params.id);
    console.log("result-->", result);
    if (result) {
      res.status(200).json(result);
    } else {
      res.status(200).json({ success: false, message: "No record found" });
    }
  });

  router.get("/dues/:id?/:sessionid?", fetchUser, async (req, res) => {


    console.log("req.params.id-->", req.params.id);
    feeDepositeModel.init(req.userinfo.tenantcode);
    const result = await feeDepositeModel.getPendingAmount(
      req?.params?.id,
      req?.params?.sessionid
    );
    console.log("result getpending-->", result);
    if (result) {
      res.status(200).json(result);
    } else {
      res.status(200).json({ success: false, message: "No record found" });
    }
  });

  // Read (Fetch) Record by ID
  router.get("/studentaddmission/:id", fetchUser, async (req, res) => {

    // Initialize model and fetch record by ID
    feeDepositeModel.init(req.userinfo.tenantcode);

    console.log("about to fetch deposites by student id->", req.params.id);
    const result = await feeDepositeModel.getFeeDepositeByStudentAddmissionId(req.params.id);

    console.log("result get-->", result);
    if (result) {
      res.status(200).json(result);
    } else {
      res.status(200).json({ success: false, message: "No record found" });
    }
  });

  // Update Record by ID
  router.put("/:id", fetchUser, async (req, res) => {

    const {amount, payment_date, discount, due_amount} = req.body;

    console.log('req.body while fee deposite update-->', req?.body);
    feeDepositeModel.init(req.userinfo.tenantcode);
    const resultById = await feeDepositeModel.getFeeDepositeById(req?.params?.id, null);
    console.log('resultById--->',resultById);

    if(!resultById){
      res.status(404).json({ success: false, message: "No record found!!" });
    }

    console.log('req.userinf-->',req.userinfo);
    feeDepositeModel.init(req.userinfo.tenantcode);
    const resultUpdatedFeeDeposit = await feeDepositeModel.updateRecordById(req?.params?.id, { status: 'cancelled' }, req.userinfo.tenantcode)
    console.log('resultUpdatedFeeDeposit--->',resultUpdatedFeeDeposit);
    if (!resultUpdatedFeeDeposit) {
      return res.status(400).json({ success: false, message: "Error while updating fee deposite!!" });
    }

    if(resultUpdatedFeeDeposit){

    let newDeposit = {
      student_addmission_id: req?.body?.student_addmission_id,
      amount: req?.body?.amount,
      payment_date: req?.body?.payment_date,
      payment_method: req?.body?.payment_method,
      late_fee: req?.body?.late_fee,
      remark: req?.body?.remark,
      discount: req?.body?.discount,
      sessionid: req?.body?.sessionid
    };

    console.log('newDeposit-->',newDeposit);

    feeDepositeModel.init(req.userinfo.tenantcode);
    const resultFeeDepositeCreate = await feeDepositeModel.createFeeDeposite(newDeposit);
    console.log('resultFeeDepositeCreate-->',resultFeeDepositeCreate);
    if (!resultFeeDepositeCreate) {
      return res.status(400).json({ success: false, message: "Error while creating fee deposite!!" });
    }

    if(resultFeeDepositeCreate){
      student_fee_installments.init(req.userinfo.tenantcode);
      const studentInstallmentByDepositId = await student_fee_installments.fetchRecordById(resultById.id);

      console.log('studentInstallmentByDepositId-->',studentInstallmentByDepositId);
      if(!studentInstallmentByDepositId){
        return res.status(404).json({ success: false, message: "Student fee installment not found" });
      }

    student_fee_installments.init(req.userinfo.tenantcode);
     const resultCon = await student_fee_installments.updateRecordById(studentInstallmentByDepositId.id, {deposit_id: resultFeeDepositeCreate.id}, req.userinfo.id);
     console.log('student fee installment updated with deposit id-->',resultCon);
    }

    if (resultFeeDepositeCreate) {
      res.status(200).json({success: true,message: "Record updated successfully",result: resultFeeDepositeCreate,});
    } else {
      res.status(400).json({ success: false, message: "Bad Request" });
    }
  }
  });

  // Delete Record by ID
  router.delete("/:id", fetchUser, async (req, res) => {


    // Initialize model and delete record by ID
    feeDepositeModel.init(req.userinfo.tenantcode);
    const result = await feeDepositeModel.deleteFeeDeposite(req.params.id);

    if (result) {
      res
        .status(200)
        .json({ success: true, message: "Record deleted successfully" });
    } else {
      res.status(200).json({ success: false, message: "No record found" });
    }
  });

  app.use("/api/feedeposites", router);
};
