using {db as sch} from '../db/schema';

service MyFirtsService {
    entity Products as projection on sch.Products
}
