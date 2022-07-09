using com.Laboratorio as Laboratorio from '../db/schema';
using {com.training as training} from '../db/training';


// service MyFirtsServices1234 {
//     entity Products        as projection on Laboratorio.materials.Products;
//     entity Suppliers       as projection on Laboratorio.sales.Suppliers;
//     entity Currency        as projection on Laboratorio.materials.Currencies;
//     entity DimensionUnits  as projection on Laboratorio.materials.DimensionUnits;
//     entity Category        as projection on Laboratorio.materials.Categories;
//     entity SalesDate       as projection on Laboratorio.sales.SalesDate;
//     entity Reviews         as projection on Laboratorio.materials.ProductReview;
//     entity UnitOfMeasures  as projection on Laboratorio.materials.UnitOfMeasures;
//     entity Months          as projection on Laboratorio.sales.Months;
//     entity Order           as projection on Laboratorio.sales.Orders;
//     entity OrderItems      as projection on Laboratorio.sales.OrderItems;
//     entity Course          as projection on training.Course;
//     entity Student         as projection on training.Student;
//     entity StudentCourseas as projection on training.StudentCourse;
// };


define service CatalogServices {
    entity Product           as
        select from Laboratorio.Reports.Products {
            ID,
            Name           as ProductName     @mandatory,
            Description                       @mandatory,
            ImageUrl,
            ReleaseDate,
            DiscontinuedDate,
            Price                             @mandatory,
            Height,
            Width,
            Depth,
            Quantity                          @(
                mandatory,
                assert.range : [
                    0.00,
                    20.00
                ]
            ),
            UnitOfMeasures as ToUnitOfMeasure @mandatory,
            Currency       as ToCurrency      @mandatory,
            Category       as ToCategory      @mandatory,
            Category.Name  as Category        @mandatory,
            DimensionUnits as ToDimensionUnit,
            SalesDate,
            Supplier,
            Reviews,
            Rating,
            StockAvailability,
            ToStockAvailability
        };

    entity Supplier          as
        select from Laboratorio.sales.Suppliers {
            ID,
            Name,
            Email,
            Phone,
            Fax,
            Product as ToPorduct
        };

    @readonly
    entity Reviews           as
        select from Laboratorio.materials.ProductReview {
            ID,
            Name,
            Rating,
            Comment,
            createdAt,
            Product
        };

    @readonly
    entity SalesDate         as
        select from Laboratorio.sales.SalesDate {
            ID,
            DeliveryDate,
            Revenue,
            Currency.ID               as CurrencyKey,
            DeliveryMonth             as DeliveryMonthId,
            DeliveryMonth.Description as DeliveryMonth,
            Product                   as ToPorduct
        };

    @readonly
    entity StockAvailability as
        select from Laboratorio.materials.StockAvailability {
            ID,
            Description,
            Product as ToPorduct
        };

    @readonly
    entity VH_Categories     as
        select from Laboratorio.materials.Categories {
            ID   as Code,
            Name as Text
        };

    @readonly
    entity VH_Currencies     as
        select from Laboratorio.materials.Currencies {
            ID          as Code,
            Description as Text
        };

    @readonly
    entity VH_UnitOfMeasure  as
        select from Laboratorio.materials.UnitOfMeasures {
            ID          as Code,
            Description as Text
        };

    @readonly
    entity VH_DimensionUnits as
        select
            ID          as Code,
            Description as Text
        from Laboratorio.materials.DimensionUnits;
};

define service MyService {

    entity SupplierProduct as
        select from Laboratorio.materials.Products[Name = 'Bread']{
            *,
            Name,
            Description,
            Supplier.Address
        }
        where
            Supplier.Address.PostalCode = 98074;

    entity SupplierToSales as
        select
            Supplier.Email,
            Supplier.Name,
            SalesDate.Currency.ID,
            SalesDate.Currency.Description
        from Laboratorio.materials.Products;

    entity EntityInfix     as
        select Supplier[Name = 'Exotic Liquids'].Phone from Laboratorio.materials.Products
        where
            Products.Name = 'Bread';

    entity EntityJoin      as //Filtro SQL
        select Phone from Laboratorio.materials.Products
        left join Laboratorio.sales.Suppliers as Supp
            on(
                Supp.ID = Products.Supplier.ID
            )
            and Supp.Name = 'Exotic Liquids'
        where
            Products.Name = 'Bread';
};

define service Reports {

    entity AcerageRating as projection on Laboratorio.Reports.AverageRating;

};
