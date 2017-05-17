CREATE OR REPLACE FUNCTION sphinx_products() RETURNS TRIGGER AS $$
DECLARE
    index_name varchar(254);
    is_visible varchar(1);
    is_user_can_buy varchar(1);
    result text;
BEGIN

    index_name := TG_ARGV[0];
    RAISE NOTICE 'Calling products(%)', index_name;
    RAISE NOTICE 'TG_OP %', TG_OP;

    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        /* astr = NEW.name; */
        is_visible := (SELECT case when NEW.is_visible=true then 1 else 0 end)::text;
        is_user_can_buy := (SELECT case when NEW.is_user_can_buy=true then 1 else 0 end)::text;
        RAISE NOTICE 'NEW.price_2::text =>%<=', NEW.price_2::text;
        RAISE NOTICE 'NEW.id::text =>%<=', NEW.id::text;

        result := (SELECT sphinx_replace(index_name, NEW.id,
                          ARRAY[
                          'pk', NEW.id::text,
                          'name', NEW.name,
                          'article', NEW.article,
                          'description', NEW.description,
                          'is_visible', is_visible,
                          'is_user_can_buy', NEW.is_user_can_buy::text,
                          'import_rate_to_rub', NEW.import_rate_to_rub::text,
                          'min_order', NEW.min_order::text,
                          'image', NEW.image,
                          'data_sheet', to_json(NEW.data_sheet)::text,
                          'attributes', to_json(NEW.attributes)::text,
                          'price_1', NEW.price_1::text,
                          'price_2', NEW.price_2::text,
                          'price_3', NEW.price_3::text,
                          'price_4', NEW.price_4::text,
                          'price_5', NEW.price_5::text,
                          'price_6', NEW.price_6::text,
                          'price_7', NEW.price_7::text,
                          'price_8', NEW.price_8::text,
                          'stock_1', NEW.stock_1::text,
                          'stock_2', NEW.stock_2::text,
                          'stock_3', NEW.stock_3::text,
                          'stock_4', NEW.stock_4::text,
                          'stock_5', NEW.stock_5::text,
                          'stock_6', NEW.stock_6::text,
                          'stock_7', NEW.stock_7::text,
                          'stock_8', NEW.stock_8::text,
                          'supplier_id', NEW.supplier_id::text,
                          'catalog_id', NEW.catalog_id::text,
                          'quantity', NEW.quantity::text,
                          'quantity_in_box', NEW.quantity_in_box::text,
                          'quantity_in_box_special', NEW.quantity_in_box_special::text,
                          'discount_percent', NEW.discount_percent::text
                          ]));

        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        result := sphinx_delete(index_name, OLD.id);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;


/********* ProductOther *********/
DROP TRIGGER IF EXISTS trigger_productother ON product_productother;

CREATE TRIGGER trigger_ProductOther
AFTER INSERT OR UPDATE OR DELETE ON product_productother FOR EACH ROW EXECUTE PROCEDURE sphinx_products ("product_index");


/********* ProductFarnell *********/
DROP TRIGGER IF EXISTS trigger_productfarnell ON farnell_productfarnell;

CREATE TRIGGER trigger_ProductFarnell
AFTER INSERT OR UPDATE OR DELETE ON farnell_productfarnell FOR EACH ROW EXECUTE PROCEDURE sphinx_products ("farnell_index");


/********* ProductFutureElectronics *********/
DROP TRIGGER IF EXISTS trigger_productfutureelectronics ON future_electronics_productfutureelectronics;

CREATE TRIGGER trigger_ProductFutureElectronics
AFTER INSERT OR UPDATE OR DELETE ON future_electronics_productfutureelectronics FOR EACH ROW EXECUTE PROCEDURE sphinx_products ("future_electronics_index");


/********* ProductCompel *********/
DROP TRIGGER IF EXISTS trigger_productcompel ON compel_productcompel;

CREATE TRIGGER trigger_ProductCompel
AFTER INSERT OR UPDATE OR DELETE ON compel_productcompel FOR EACH ROW EXECUTE PROCEDURE sphinx_products ("compel_index");


/********* ProductSchukat *********/
DROP TRIGGER IF EXISTS trigger_productschukat ON schukat_productschukat;

CREATE TRIGGER trigger_ProductSchukat
AFTER INSERT OR UPDATE OR DELETE ON schukat_productschukat FOR EACH ROW EXECUTE PROCEDURE sphinx_products ("schukat_index");


/********* ProductTme *********/
DROP TRIGGER IF EXISTS trigger_producttme ON tme_producttme;

CREATE TRIGGER trigger_ProductTme
AFTER INSERT OR UPDATE OR DELETE ON tme_producttme FOR EACH ROW EXECUTE PROCEDURE sphinx_products ("tme_index");


/********* ProductArrow *********/
DROP TRIGGER IF EXISTS trigger_productarrow ON arrow_productarrow;

CREATE TRIGGER trigger_ProductArrow
AFTER INSERT OR UPDATE OR DELETE ON arrow_productarrow FOR EACH ROW EXECUTE PROCEDURE sphinx_products ("arrow_index");


/********* ProductAmerica2 *********/
DROP TRIGGER IF EXISTS trigger_productamerica2 ON america2_productamerica2;

CREATE TRIGGER trigger_ProductAmerica2
AFTER INSERT OR UPDATE OR DELETE ON america2_productamerica2 FOR EACH ROW EXECUTE PROCEDURE sphinx_products ("america2_index");


/********* ProductPlatan *********/
DROP TRIGGER IF EXISTS trigger_productplatan ON platan_productplatan;

CREATE TRIGGER trigger_ProductPlatan
AFTER INSERT OR UPDATE OR DELETE ON platan_productplatan FOR EACH ROW EXECUTE PROCEDURE sphinx_products ("platan_index");


/********* ProductMouser *********/
DROP TRIGGER IF EXISTS trigger_productmouser ON mouser_productmouser;

CREATE TRIGGER trigger_ProductMouser
AFTER INSERT OR UPDATE OR DELETE ON mouser_productmouser FOR EACH ROW EXECUTE PROCEDURE sphinx_products ("mouser_index");


/********* ProductDigikey *********/
DROP TRIGGER IF EXISTS trigger_productdigikey ON digikey_productdigikey;

CREATE TRIGGER trigger_ProductDigikey
AFTER INSERT OR UPDATE OR DELETE ON digikey_productdigikey FOR EACH ROW EXECUTE PROCEDURE sphinx_products ("digikey_index");


/********* ProductEmbest *********/
DROP TRIGGER IF EXISTS trigger_productembest ON embest_productembest;

CREATE TRIGGER trigger_ProductEmbest
AFTER INSERT OR UPDATE OR DELETE ON embest_productembest FOR EACH ROW EXECUTE PROCEDURE sphinx_products ("embest_index");


