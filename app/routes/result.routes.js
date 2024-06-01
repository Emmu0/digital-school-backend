/**
 * @author: Pawan Singh Sisodiya
 */

const {
  createGradeMaster,
  getGradeMasters,
  getGradeMasterById,
  updateGradeMasterById,
  deleteGradeMaster,
  createResult,
  getAllResults,
  getResultById,
  updateResultById,
  deleteResultById,
  init,
  updateAllResult,
  CreateAllResult,
} = require("../models/result.model.js");

//const permissions = require("../constants/permissions.js");
const { fetchUser } = require("../middleware/fetchuser.js");

module.exports = (app) => {
  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  //   ------------------- Create Grade Master ------------------
  router.post(
    "/grade",
    fetchUser,
    [
      body("grade").notEmpty().isString(),
      body("from").notEmpty().isInt(),
      body("to").notEmpty().isInt(),
    ],
    async (req, res) => {
      // Check permissions
   
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const gradeData = req.body;
      init(req.userinfo.tenantcode);
      const gradeResult = await createGradeMaster(gradeData);

      if (!gradeResult) {
        return res.status(400).json({ error: "Bad Request" });
      }
      return res.status(201).json(gradeResult);
    }
  );

  //  -------------------- Get All Grades---------------------
  router.get("/grade", fetchUser, async (req, res) => {
    // Check permissions
   
    init(req.userinfo.tenantcode);
    const grades = await getGradeMasters();
    if (grades) {
      res.status(200).json(grades);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });

  // ----------------------- Get Grade by ID ---------------------------
  router.get("/grade/:id", fetchUser, async (req, res) => {
    try {
      

      const gradeId = req.params.id;
      init(req.userinfo.tenantcode);
      const grade = await getGradeMasterById(gradeId);

      if (grade) {
        return res.status(200).json(grade);
      } else {
        return res
          .status(404)
          .json({ success: false, message: "Grade not found" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(400).json({ success: false, message: error });
    }
  });

  // ---------------------- Update Grade by ID ------------------------
  router.put(
    "/grade/:id",
    fetchUser,
    [
      body("grade").notEmpty().isString(),
      body("from").notEmpty().isInt(),
      body("to").notEmpty().isInt(),
    ],
    async (req, res) => {
      

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const gradeId = req.params.id;
      const gradeData = req.body;
      init(req.userinfo.tenantcode);
      const updatedGrade = await updateGradeMasterById(gradeId, gradeData);

      if (!updatedGrade) {
        return res.status(404).json({ error: "Grade not found" });
      }

      return res.status(200).json(updatedGrade);
    }
  );

  // ------------------- Delete Grade by ID ---------------------
  router.delete("/grade/:id", fetchUser, async (req, res) => {
    try {
      
      const gradeId = req.params.id;
      init(req.userinfo.tenantcode);
      const deleteResult = await deleteGradeMaster(gradeId);

      if (deleteResult) {
        return res
          .status(200)
          .json({ success: true, message: "Grade deleted successfully" });
      } else {
        return res
          .status(404)
          .json({ success: false, message: "Grade not found" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(400).json({ success: false, message: error });
    }
  });

  //   ----------------------------------------------------------------------
  //     ------------------- Routes For Result  ------------------
  //    ----------------------------------------------------------------------

  //---------------------- Create Result ------------------------------
  router.post("/create_result", fetchUser, async (req, res) => {
    // Check permissions
   
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    console.log(req.body, "req.body update==>1");
    const resultData = req.body;
    init(req.userinfo.tenantcode);

    Promise.all(
      resultData.map((resultVL, ky) => {
        return getGradeMasters().then((res) => {
          const matchingGrade = res.find(
            (grade) =>
              resultVL.obtained_marks >= grade.from &&
              resultVL.obtained_marks <= grade.to
          );

          if (matchingGrade) {
            resultVL.grade_master_id = matchingGrade.id;
          } else {
            return res
              .status(404)
              .json({
                success: false,
                message: "enter marks are not between 80 <> 100",
              });
          }
        });
      })
    ).then(async () => {
      init(req.userinfo.tenantcode);

      const result = await CreateAllResult(resultData);
      console.log(resultData, "resultData");
      if (!result) {
        return res
          .status(404)
          .json({ success: false, error: "Result not found" });
      }
      return res
        .status(200)
        .json({ success: true, message: "Obitain marks Created" });;
    });
  });

  // ------------------------ Get All Results ---------------------------
  router.get("/result", fetchUser, async (req, res) => {
    
    init(req.userinfo.tenantcode);
    const results = await getAllResults();
    if (results) {
      res.status(200).json(results);
    } else {
      res.status(400).json({ errors: "No data" });
    }
  });

  // -------------------------- Get Result by ID ClassId, And Schedule Id ---------------------------
  router.post(
    "/students",
    fetchUser,
    [
      body("classId").notEmpty().isUUID(),
      body("scheduleId").notEmpty().isUUID(),
    ],
    async (req, res) => {
     

      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const Ids = req.body;
      // console.log('Ids==>',Ids);
      init(req.userinfo.tenantcode);
      const result = await getResultById(Ids.scheduleId, Ids.classId);

      if (!result) {
        return res.status(400).json({ error: "Bad Request" });
      }
      return res.status(201).json(result);
    }
  );

  // ----------------------------Update Result -------------------------
  router.put("/result", fetchUser, async (req, res) => {
    

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const resultId = req.params.id;
    const updatedResultData = req.body;
    console.log(req.body, req.params.id, "req.body +++>");

    init(req.userinfo.tenantcode);
    const gradePromises = updatedResultData.map((resultVL, ky) => {
      return getGradeMasters().then((res) => {

        const matchingGrade = res.find((grade) => {
          return (
            resultVL.obtained_marks >= grade.from &&
            resultVL.obtained_marks <= grade.to
          );
        });

        if (matchingGrade) {
          resultVL.grade_master_id = matchingGrade.id;
        } else {
          return res
            .status(404)
            .json({
              success: false,
              message: "enter marks are not between 80 <> 100",
            });
        }
      });
    });

    Promise.all(gradePromises)
      .then(async () => {
        const updatedResult = await updateAllResult(updatedResultData);
        if (!updatedResult) {
          return res
            .status(404)
            .json({ success: false, error: "Result not found" });
        }
        return res
          .status(200)
          .json({ success: true, message: "Obitain marks Updated" });
      })
      .catch((error) => {
        return res.status(500).json({ success: true, error: "Internal server error" });
      });
  });


  // ------------------- Delete Result by ID ------------------------
  router.delete("/result/:id", fetchUser, async (req, res) => {
    try {
      
      const resultId = req.params.id;
      init(req.userinfo.tenantcode);
      const deleteResult = await deleteResultById(resultId);

      if (deleteResult) {
        return res
          .status(200)
          .json({ success: true, message: "Result deleted successfully" });
      } else {
        return res
          .status(404)
          .json({ success: false, message: "Result not found" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(400).json({ success: false, message: error });
    }
  });

  app.use(process.env.BASE_API_URL + "/api/results", router);
};
