/**
 * Handles all incoming request for /api/StudentAddmision endpoint
 * DB table for this public.StudentAddmision
 * Model used here is StudentAddmision.model.js
 * SUPPORTED API ENDPOINTS
 *              GET     /api/StudentAddmision
 *              GET     /api/StudentAddmision/:id
 *              POST    /api/StudentAddmision
 *              PUT     /api/StudentAddmision/:id
 *              DELETE  /api/StudentAddmision/:id
 * 
 * @author      Farhan Khan
 * @date        June, 2023
 * @copyright   www.ibirdsservices.com  
 */

const e = require("express");
const { fetchUser } = require("../middleware/fetchuser.js");
const StudentAddmision = require("../models/studentaddmission.model.js");
//const permissions = require("../constants/permissions.js");
const feeDepositeModel = require("../models/fee_deposite.model.js");
const feeMasterLineItemsModel = require("../models/fee_master_installment.model.js");
const assignTransport = require("../models/assign_transport.model.js");
const student_fee_installments = require("../models/student_fee_installments.model.js")


module.exports = app => {
  const { body, validationResult } = require('express-validator');
  var router = require("express").Router();

  // ................................ Create a new Student Addmission ................................
  router.post("/", fetchUser, [ /* body('studentid', 'Please enter Student Name').isLength({ min: 1 }), */], async (req, res) => {

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    // console.log('req.body while studentadd-->', req.body);
    StudentAddmision.init(req.userinfo.tenantcode);
    const studentAddmisionRec = await StudentAddmision.create(req.body, req.userinfo.id);

    if (!studentAddmisionRec) {
      return res.status(400).json({ errors: "Bad Request" });
    }
    return res.status(201).json(studentAddmisionRec);

  });

  // .....................................Get All Rte Student Addmision........................................
  router.get("/getrte", fetchUser, async (req, res) => {

    StudentAddmision.init(req.userinfo.tenantcode);
    const studentAddmisions = await StudentAddmision.findAllRteAddmission();
    if (studentAddmisions) {
      res.status(200).json(studentAddmisions);
    } else {
      res.status(200).json({ errors: "No data" });
    }
  })
  // .....................................Get All Student Addmision........................................
  router.get("/admission?/student_id?/:student_id?", fetchUser, async (req, res) => {
    // console.log('/student/:student_id=>', req.params)
    let studentId = req.params.student_id === 'null' ? null : req.params.student_id;

    StudentAddmision.init(req.userinfo.tenantcode);
    const studentAddmisions = await StudentAddmision.findAll(studentId);
    if (studentAddmisions) {
      res.status(200).json(studentAddmisions);
    } else {
      res.status(200).json({ errors: "No data" });
    }
  });



  router.get("/student_id/:student_id", fetchUser, async (req, res) => {
    console.log('/student/:student_id=>', req.params)


    StudentAddmision.init(req.userinfo.tenantcode);
    const studentAddmisions = await StudentAddmision.findAdmissionByStudentId(req.params.student_id);
    if (studentAddmisions) {
      res.status(200).json(studentAddmisions);
    } else {
      res.status(200).json({ errors: "No data" });
    }
  });
  //......................................Get Student Addmisions by StudentId.................................
  router.get("/:id", fetchUser, async (req, res) => {
    try {

      StudentAddmision.init(req.userinfo.tenantcode);
      let resultCon = await StudentAddmision.findById(req.params.id);
      if (resultCon) {
        return res.status(200).json(resultCon);
      } else {
        return res.status(200).json({ "success": false, "message": "No record found" });
      }
    } catch (error) {
      return res.status(400).json({ "success": false, "message": error });
    }
  });

  //......................................Update Student Addmisions.................................
  router.put("/:id", fetchUser, async (req, res) => {
    try {


      // console.log('req.body=>', req.body)
      const { studentid, classid, dateofaddmission, year, formno, parentid, fee_type, session_id } = req.body;
      const errors = [];
      const studentAddmissionRec = {};
      if (req.body.hasOwnProperty("studentid")) {
        studentAddmissionRec.studentid = studentid;
      }
      if (req.body.hasOwnProperty("classid")) {
        studentAddmissionRec.classid = classid;
      }
      if (req.body.hasOwnProperty("formno")) {
        studentAddmissionRec.formno = formno;
      }
      if (req.body.hasOwnProperty("dateofaddmission")) {
        studentAddmissionRec.dateofaddmission = dateofaddmission;
      }
      if (req.body.hasOwnProperty("year")) {
        studentAddmissionRec.year = year;
      }
      if (req.body.hasOwnProperty("parentid")) {
        studentAddmissionRec.parentid = parentid;
      }
      if (req.body.hasOwnProperty("fee_type")) {
        studentAddmissionRec.fee_type = fee_type;
      }
      console.log('studentAddmissionRec@@@=>', studentAddmissionRec)
      if (errors.length !== 0) {
        return res.status(400).json({ errors: errors });
      }
      // console.log('req.params.id@@@=>',req.params.id)
      StudentAddmision.init(req.userinfo.tenantcode);
      let resultCon = await StudentAddmision.findById(req.params.id);
      console.log('resultCon-->', resultCon);
      console.log('req.body-->', req.body);
      console.log('session_id-->', session_id);

      let usercategory = req.body.category;
      console.log('usercategory-->', usercategory);

      if (resultCon && resultCon?.fee_type !== studentAddmissionRec?.fee_type) {
        console.log('inside deposite management-->');

        //getting deposite records if user has
        feeDepositeModel.init(req.userinfo.tenantcode);
        const resultDepositByStudentId = await feeDepositeModel.getFeeDepositeById(req.params.id, req?.body?.session_id);
        console.log('resultDepositByStudentId-->', resultDepositByStudentId);

        let totalDepositedAmount = 0;
        if (resultDepositByStudentId) {
          console.log('inside first step->')
          for (let i = 0; i < resultDepositByStudentId.length; i++) {
            totalDepositedAmount += parseInt(resultDepositByStudentId[i].amount);

            let depoid = resultDepositByStudentId[i].id;
            delete resultDepositByStudentId[i].id;
            feeDepositeModel.init(req.userinfo.tenantcode);
            const resultUpdatedFeeDeposit = await feeDepositeModel.updateRecordById(depoid, { status: 'cancelled' }, req.userinfo)
            console.log('resultUpdatedFeeDeposit-->', resultUpdatedFeeDeposit);
            if (!resultUpdatedFeeDeposit) {
              return res.status(400).json({ success: false, message: "Error while updating fee deposite!!" });
            }
          }
          console.log('totalDepositedAmount-->', totalDepositedAmount);
        }

        //------------------------------------------------

        if (studentAddmissionRec?.fee_type) {

          feeMasterLineItemsModel.init(req.userinfo.tenantcode);
          const feeMasterRecord = await feeMasterLineItemsModel.getRecordById(studentAddmissionRec?.fee_type);
          console.log('feeMaster installment Record- by new type->', feeMasterRecord);

          if (!feeMasterRecord) {
            return res.status(400).json({ success: false, message: "Master installment records not found!!" });
          }

          assignTransport.init(req.userinfo.tenantcode);
          const transportRecord = await assignTransport.fetchRecordById(req?.params?.id);
          console.log('transport record-->', transportRecord);

          let transportFeeByInstall = 0;
          if (transportRecord) {
            transportFeeByInstall = parseInt(transportRecord?.fare_amount) / feeMasterRecord.length
          }

          let recordsForStudentInstallment = [];


          console.log('transportFeeByInstall-->', transportFeeByInstall);

          //getting old student_fee_installments
          student_fee_installments.init(req.userinfo.tenantcode);
          const previousCreatedInstallments = await student_fee_installments.fetchRecordById(req?.params?.id);

          if (previousCreatedInstallments) {
            for (let i = 0; i < previousCreatedInstallments?.length; i++) {
              student_fee_installments.init(req.userinfo.tenantcode);
              const deleteResult = await student_fee_installments.deleteRecord(previousCreatedInstallments[i]?.id);
              if (!deleteResult) {
                return res.status(400).json({ success: false, message: "Error While deleting old student fee installments!!" });
              }
            }
          }

          // if (resultDepositByStudentId) {

          const today = new Date();
          function formatDate(date, format) {
            const dd = String(date.getDate()).padStart(2, '0');
            const mm = String(date.getMonth() + 1).padStart(2, '0');
            const yyyy = String(date.getFullYear());

            format = format.toLowerCase();
            format = format.replace('dd', dd);
            format = format.replace('mm', mm);
            format = format.replace('yyyy', yyyy);

            return format;
          }

          console.log(formatDate(today, 'dd/mm/yyyy'));
          console.log('totalDepositedAmount-->', totalDepositedAmount);
          console.log('resultDepositByStudentId[0]?.payment_method -->', resultDepositByStudentId);

          let newDeposit = {
            student_addmission_id: req?.params?.id,
            amount: totalDepositedAmount,
            payment_date: formatDate(today, 'dd/mm/yyyy'),
            payment_method: resultDepositByStudentId ? resultDepositByStudentId[0]?.payment_method : null,
            late_fee: resultDepositByStudentId ? resultDepositByStudentId[0]?.late_fee : 0,
            remark: resultDepositByStudentId ? resultDepositByStudentId[0]?.remark : null,
            discount: resultDepositByStudentId ? resultDepositByStudentId[0]?.discount : 0,
            sessionid: session_id
          };
          console.log('hi prince888888');
          console.log('newDeposit-->', newDeposit);

          feeDepositeModel.init(req.userinfo.tenantcode);
          const resultFeeDepositeCreate = await feeDepositeModel.createFeeDeposite(newDeposit, req.userinfo.id);
          if (resultFeeDepositeCreate) {
            console.log('resultFeeDepositeCreate- after new installments->', resultFeeDepositeCreate);
          }

          if (feeMasterRecord) {
            const transportFee = Math.ceil(transportFeeByInstall || 0);
            console.log('transportFee-->', transportFee);
            // console.log('res-prince->', res, usercategory);

            let categoryFee = '';
            if (usercategory === 'General') {
              categoryFee = 'general_fee'
            }
            else if (usercategory === 'Obc') {
              categoryFee = 'obc_fee'
            }
            else if (usercategory === 'Sc') {
              categoryFee = 'sc_fee'
            }
            else if (usercategory === 'St') {
              categoryFee = 'st_fee'
            }

            // console.log('res.categoryFee-->',res.categoryFee);
            console.log('categoryFee-->', categoryFee);

            // const resultPendingAmount = await 
            feeDepositeModel.init(req.userinfo.tenantcode);
            const resultPendingAmount = await feeDepositeModel.getPendingAmount(req?.params?.id, session_id);
            console.log('resultPendingAmount-->', resultPendingAmount);

            //------------------ creating new installment --------------
            let depositedAmount = parseInt(totalDepositedAmount);
            let pendingAmount = resultPendingAmount ? parseInt(resultPendingAmount?.dues) : 0;
            console.log('pendingAmount-->', pendingAmount);
            console.log('depositedAmount-outside->', depositedAmount);
            feeMasterRecord.forEach((res, index) => {
              console.log('res@@-->', res);
              console.log('result.categoryFee-->', res[categoryFee]);

              let newInstallment = {};
              if (depositedAmount > 0 && depositedAmount >= parseInt(res[categoryFee])) {
                console.log('depositedAmount-inside->', depositedAmount);
                newInstallment = {
                  student_addmission_id: req?.params?.id,
                  fee_master_installment_id: res?.id,
                  amount: res[categoryFee],
                  status: 'completed',
                  previous_due: 0,
                  deposit_id: resultFeeDepositeCreate.id,
                  orderno: index + 1,
                  session_id: req?.body?.session_id,
                  transport_fee: transportFee ? transportFee : 0,
                  assign_transport_id: transportRecord?.id || null,
                  month: res?.month,
                };
                depositedAmount -= parseInt(res[categoryFee]);
                console.log('depositedAmount-inside- after complete>', depositedAmount);

              } else if (depositedAmount > 0 && depositedAmount < parseInt(res[categoryFee])) {

                let installmentRemainingAmount = res[categoryFee] - depositedAmount;
                console.log('depositedAmount-inside->', depositedAmount);
                newInstallment = {
                  student_addmission_id: req?.params?.id,
                  fee_master_installment_id: res?.id,
                  deposit_id: resultFeeDepositeCreate.id,
                  amount: installmentRemainingAmount,
                  status: 'pending',
                  previous_due: pendingAmount,
                  orderno: index + 1,
                  session_id: req?.body?.session_id,
                  transport_fee: transportFee ? transportFee : 0,
                  assign_transport_id: transportRecord?.id || null,
                  month: res?.month,
                };
                depositedAmount = 0;
                pendingAmount = 0;
                console.log('depositedAmount-inside- after pending>', depositedAmount);

              }
              else if (depositedAmount === 0) {
                newInstallment = {
                  student_addmission_id: req?.params?.id,
                  fee_master_installment_id: res?.id,
                  amount: res[categoryFee],
                  status: 'pending',
                  previous_due: pendingAmount,
                  orderno: index + 1,
                  session_id: req?.body?.session_id,
                  transport_fee: transportFee ? transportFee : 0,
                  assign_transport_id: transportRecord?.id || null,
                  month: res?.month,
                };
                pendingAmount = 0;
              }

              console.log('newInstallment-->', newInstallment);

              recordsForStudentInstallment.push(newInstallment);
            });
          }

          // }

          console.log('recordsForStudentInstallment-final->', recordsForStudentInstallment);


          let studentFeeInstallmentResults = [];
          for (let i = 0; i < recordsForStudentInstallment.length; i++) {
            console.log(`Processing record ${i + 1}`, recordsForStudentInstallment[i]);

            // recordsForStudentInstallment[i]?.deposit_id = resultFeeDepositeCreate.id

            student_fee_installments.init(req.userinfo.tenantcode);
            const studentFeeInstallmentResult = await student_fee_installments.addRecord(recordsForStudentInstallment[i], req.userinfo.id);
            console.log('studentFeeInstallmentResult:', studentFeeInstallmentResult);

            studentFeeInstallmentResults.push(studentFeeInstallmentResult);
          }
          if (!studentFeeInstallmentResults) {
            return res.status(400).json({ success: false, message: "Error While creating new student fee installments!!" });
          }


        }
      }

      //------------------------------------------------


      console.log("resultCon staddd", resultCon);
      if (resultCon) {
        resultCon = await StudentAddmision.updateById(
          req.params.id,
          studentAddmissionRec,
          req.userinfo.id
        );
        // console.log("resultCon stadd update", resultCon);
        if (resultCon) {
          return res
            .status(200)
            .json({ success: true, message: "Record updated successfully" });
        }
        return res.status(200).json(resultCon);
      } else {
        return res
          .status(200)
          .json({ success: false, message: "No record found" });
      }
    } catch (error) {
      console.log('errors=>', error)
      res.status(400).json({ errors: error });
    }
  });

  // Delete a Tutorial with id
  router.delete("/:id", fetchUser, async (req, res) => {
    //Check permissions

    StudentAddmision.init(req.userinfo.tenantcode);
    const result = await StudentAddmision.deletestudentaddmision(req.params.id);
    if (!result)
      return res.status(200).json({ "success": false, "message": "No record found" });

    res.status(200).json({ "success": true, "message": "Successfully Deleted" });
  });

  app.use('/api/studentaddmissions', router);
};