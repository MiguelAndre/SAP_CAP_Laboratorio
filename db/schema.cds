namespace com.Laboratorio;

using {
    cuid,
    managed
} from '@sap/cds/common';


type Name : String(50);

type Address {
    Street     : String;
    City       : String;
    State      : String(2);
    PostalCode : String(5);
    Country    : String(3);
};

context materials {
    entity Products : cuid, managed {
        Name             : localized String not null;
        Description      : localized String;
        ImageUrl         : String;
        ReleaseDate      : DateTime default $now;
        DiscontinuedDate : DateTime;
        Price            : Decimal(16, 2);
        Height           : type of Price;
        Width            : Decimal(16, 2);
        Depth            : Decimal(16, 2);
        Quantity         : Decimal(16, 2);
        Supplier         : Association to sales.Suppliers;
        UnitOfMeasures   : Association to UnitOfMeasures;
        Currency         : Association to Currencies;
        DimensionUnits   : Association to DimensionUnits;
        Category         : Association to Categories;
        SalesDate        : Association to many sales.SalesDate
                               on SalesDate.Product = $self;
        Reviews          : Association to many ProductReview
                               on Reviews.Product = $self;
    };

    entity Categories {
        key ID   : String(1);
            Name : localized String;
    };

    entity StockAvailability {
        key ID          : Integer;
            Description : localized String;
            Product     : Association to Products;
    };

    entity Currencies {
        key ID          : String(3);
            Description : localized String;
    };

    entity UnitOfMeasures {
        key ID          : String(2);
            Description : localized String;
    };

    entity DimensionUnits {
        key ID          : String(2);
            Description : localized String;
    };

    entity ProductReview : cuid, managed {
        Name    : String;
        Rating  : Integer;
        Comment : String;
        Product : Association to Products;
    };

    entity SelProducts   as select from Products;
    entity ProjProducts  as projection on Products;

    entity ProjProducts2 as projection on Products {
        *
    };

    entity ProjProducts3 as projection on Products {
        ReleaseDate,
        Name
    };

    extend Products {
        PriceCondition     : String(2);
        PreciDetermination : String(3);
    };

};

context sales {
    entity Orders : cuid {
        Date     : Date;
        Customer : String;
        Items    : Composition of many OrderItems
                       on Items.Order = $self;
    };

    entity OrderItems : cuid {
        Order    : Association to Orders;
        Product  : Association to materials.Products;
        Quantity : Integer;
    }

    entity Suppliers : cuid, managed {
        Name    : materials.Products:Name;
        Address : Address;
        Email   : String;
        Phone   : String;
        Fax     : String;
        Product : Association to many materials.Products
                      on Product.Supplier = $self;
    };

    entity Months {
        key ID               : String(2);
            Description      : localized String;
            ShortDescription : localized String(3);
    };


    entity SelProducts1 as
        select from materials.Products {
            *
        };

    entity SelProducts2 as
        select from materials.Products {
            Name,
            Price,
            Quantity
        };

    entity SelProducts3 as
        select from materials.Products
        left join materials.ProductReview
            on Products.Name = ProductReview.Name
        {
            Rating,
            Products.Name,
            sum(Price) as TotalPrice
        }
        group by
            Rating,
            Products.Name
        order by
            Rating;

    entity SalesDate : cuid, managed {
        DeliveryDate  : DateTime;
        Revenue       : Decimal(16, 2);
        Product       : Association to materials.Products;
        Currency      : Association to materials.Currencies;
        DeliveryMonth : Association to Months;
    };
};

context Reports {

    entity AverageRating as
        select from Laboratorio.materials.ProductReview {
            Product.ID  as ProductId,
            avg(Rating) as AcerageRating : Decimal(16, 2)
        }
        group by
            Product.ID;

    entity Products      as
        select from Laboratorio.materials.Products
        mixin {
            ToStockAvailability : Association to Laboratorio.materials.StockAvailability
                                      on ToStockAvailability.ID = $projection.StockAvailability;
            ToAverageRating     : Association to Laboratorio.Reports.AverageRating
                                      on ToAverageRating.ProductId = ID;
        }
        into {
            *,
            ToAverageRating as Rating,
            case
                when
                    Quantity >= 8
                then
                    3
                when
                    Quantity > 0
                then
                    2
                else
                    1
            end             as StockAvailability : Integer,
            ToStockAvailability
        };

    entity EntityCatsing as
        select
            cast(Price as Integer) as Price,
            Price                  as Price2 : Integer
        from Laboratorio.materials.Products;

    entity EntityExists  as
        select from Laboratorio.materials.Products {
            Name
        }
        where
            exists Supplier[Name = 'Exotic Liquids'];
};
