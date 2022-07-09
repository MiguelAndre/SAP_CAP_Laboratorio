const cds = require("@sap/cds");
const { Orders } = cds.entities("com.training");

module.exports = (srv) => {
    //*********READ*******/
    srv.on("READ", "GetOrders", async (req) => {
        if (req.data.ClientEmail !== undefined) {
            return await SELECT.from`com.training.Orders`
                .where`ClientEmail = ${req.data.ClientEmail}`;
        };
        return await SELECT.from(Orders);
    });

    srv.after("READ", "GetOrders", (data) => {
        return data.map((Orders) => (Orders.Reviewed = true));
    });

    //********CREATE********/
    srv.on("CREATE", "CreateOrders", async (req) => {
        let returnData = await cds
            .transaction(req)
            .run(
                INSERT.into(Orders).entries({
                    ClientEmail: req.data.ClientEmail,
                    FirstName: req.data.FirstName,
                    LastName: req.data.LastName,
                    CreatedOn: req.data.CreatedOn,
                    Reviewed: req.data.Reviewed,
                    Approved: req.data.Approved,
                })
            )
            .then((resolve, reject) => {
                console.log("Resolve", resolve);
                console.log("Reject", reject);

                if (typeof resolve !== "undefined") {
                    return req.data;
                } else {
                    req.error(409, "No encontrada");
                }
            })
            .catch((err) => {
                console.log("Error:", err);
                req.error(err.code, err.message);
            });
        console.log("Before End", returnData);
        return returnData;
    });

    srv.before("CREATE", "CreateOrders", (req) => {
        req.data.CreatedOn = new Date().toISOString().slice(0, 10);
        return req;
    });

    //********UPDATE********/       
    srv.on("UPDATE", "UpdateOrders", async (req) => {
        let returnData = await cds
            .transaction(req)
            .run([
                UPDATE(Orders, req.data.ClientEmail).set({
                    FirstName: req.data.FirstName,
                    LastName: req.data.LastName,
                }),
            ])
            .then((resolve, reject) => {
                console.log("Resolve: ", resolve);
                console.log("Reject: ", reject);

                if (resolve[0] == 0) {
                    req.error(409, "No encontrado");
                }
            })
            .catch((err) => {
                console.log(err.code, err.message);
            });
        console.log("Before End", returnData);
        return returnData;
    });

    //********DELETE********/   
    srv.on("DELETE", "DeleteOrders", async (req) => {
        let returnData = await cds
            .transaction(req)
            .run(
                DELETE.from(Orders).where({
                    ClientEmail: req.data.ClientEmail,
                })
            )
            .then(async (resolve, reject) => {
                console.log("Resolve: ", resolve);
                console.log("Rejects: ", reject);

                if (resolve !== 1) {
                    req.error(409, "No Borrado");
                }
            })
            .catch((err) => {
                console.log(err.code, err.message);
            })
        console.log("Before End", returnData);
        return returnData;
    });

    //********FUNCTION********/  
    srv.on("getClientTaxRate", async (req) => {
        //NO server side-efect
        const { ClientEmail } = req.data;
        const db = srv.transaction(req);

        const results = await db
            .read(Orders, ["Country_code"])
            .where({ ClientEmail: ClientEmail });

        console.log(results[0]);

        switch (results[0].Country_code) {
            case 'ES':
                return '21.5';
            case 'UK':
                return '24.6';
            default:
                return '0.0';
        };
    });

    //********ACTION********/  
    srv.on("cancelOrder", async (req) => {
        const { ClientEmail } = req.data;
        const db = srv.transaction(req);

        const resultsRead = await db
            .read(Orders, ["FirstName", "LastName", "Approved"])
            .where({ ClientEmail: ClientEmail });

        let retunrOrder = {
            status: "",
            message: ""
        };

        console.log(ClientEmail);
        console.log(resultsRead);

        if (resultsRead[0].Approved == false) {
            const resultsUpdate = await db
                .update(Orders)
                .set({ Status: "C" })
                .where({ ClientEmail: ClientEmail });
            retunrOrder.status = "Succeeded"
            retunrOrder.message = `The order place by ${resultsRead[0].FirstName} ${resultsRead[0].LastName} was canceled ${resultsUpdate}`;
        } else {
            retunrOrder.status = "Failed";
            retunrOrder.message = `The order place by ${resultsRead[0].FirstName} ${resultsRead[0].LastName} was NOT calceled because was already approved`;
        };
        console.log("Action cancelOrder executed");
        return retunrOrder;
    });

};