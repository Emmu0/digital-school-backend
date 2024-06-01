/**
 * @author: Pawan Singh Sisodiya
 */

const {
  createSession,
  getSessionById,
  deleteSession,
  updateSessionById,
  getSession,
  createSessionTerm,
  getSessionTerms,
  updateSessionTermById,
  getSessionTermById,
  deleteSessionTerm,
  init,
} = require("../models/session.model.js");
//const permissions = require("../constants/permissions.js");
const { fetchUser } = require("../middleware/fetchuser.js");

module.exports = (app) => {
  const { body, validationResult } = require("express-validator");

  var router = require("express").Router();

  //   ------------------- Create Session ------------------
  router.post(
    "/session",
    fetchUser,
    [
      body("year").notEmpty().isString(),
      body("startdate").notEmpty().isDate(),
      body("enddate").notEmpty().isDate(),
    ],
    async (req, res) => {
      const sessionData = req.body;
      init(req.userinfo.tenantcode);
      const sessionResult = await createSession(sessionData);

      if (!sessionResult) {
        return res.status(400).json({ error: "Bad Request" });
      }
      return res.status(201).json(sessionResult);
    }
  );

  //   ---------------------Get Session ------------------

  router.get("/session", fetchUser, async (req, res) => {
    init(req.userinfo.tenantcode);
    const allSessions = await getSession();
    if (allSessions) {
      res.status(200).json(allSessions);
    } else {
      res.status(200).json({ errors: "No data" });
    }
  });

  router.get("/session/current", fetchUser, async (req, res) => {
    init(req.userinfo.tenantcode);
    const allSessions = await getSession(true); 
    if (allSessions) {
      res.status(200).json(allSessions);
    } else {
      res.status(200).json({ errors: "No data" });
    }
  });

  // ----------------------- Get Session By Id -------------------
  router.get("/session/:id", fetchUser, async (req, res) => {
    try {
      const sessionId = req.params.id;
      init(req.userinfo.tenantcode);
      const sessionRecord = await getSessionById(sessionId);
      console.log("pawan is getting records of sessions-->", sessionRecord);

      if (sessionRecord?.id) {
        return res.status(200).json({ success: true, result: sessionRecord });
      } else {
        return res
          .status(404)
          .json({ success: false, message: "No record found" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(400).json({ success: false, message: error });
    }
  });

  //   ---------------------- Delete Session -----------------------
  router.delete("/session/:id", fetchUser, async (req, res) => {
    try {
      const sessionId = req.params.id;
      init(req.userinfo.tenantcode);
      const sessionResult = await deleteSession(sessionId);

      if (sessionResult) {
        return res
          .status(200)
          .json({ success: true, message: "Session deleted successfully" });
      } else {
        return res
          .status(404)
          .json({ success: false, message: "Session not found" });
      }
    } catch (error) {
      console.log("System Error:", error);
      return res.status(400).json({ success: false, message: error });
    }
  });

  //   ----------------------- Update Session -------------------

  router.put(
    "/session/:id",
    fetchUser,
    [
      body("year").notEmpty().isString(),
      body("startdate").notEmpty().isDate(),
      body("enddate").notEmpty().isDate(),
    ],
    async (req, res) => {
      const sessionId = req.params.id; // getting id from the route parameter
      console.log("session Id to be updaetd", sessionId);
      const sessionData = req.body;
      console.log("session record to be updated", sessionData);
      init(req.userinfo.tenantcode);
      const updatedSession = await updateSessionById(sessionId, sessionData);

      if (!updatedSession) {
        return res.status(404).json({ error: "Session not found" });
      }

      return res.status(200).json(updatedSession);
    }
  );

  app.use(process.env.BASE_API_URL + "/api/sessions", router);
};
