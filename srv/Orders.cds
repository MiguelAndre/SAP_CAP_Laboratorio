using com.training as training from '../db/training';

service ManageOrders {
    type CancelOrdersReturn {
        status  : String enum {
            Succeeded;
            Failed
        };
        message : String;
    };

    // function getClientTaxRate(ClientEmail : String(65)) returns Decimal(4, 2);
    // action   cancelOrder(ClientEmail : String(65))      returns CancelOrdersReturn;

    entity Orders as projection on training.Orders actions {
        function getClientTaxRate(ClientEmail : String(65)) returns Decimal(4, 2);
        action   cancelOrder(ClientEmail : String(65))      returns CancelOrdersReturn;
    }
};
