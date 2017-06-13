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
        RAISE NOTICE 'is_user_can_buy =>%<=', is_user_can_buy;

        result := (SELECT sphinx_replace(index_name, NEW.id,
                          ARRAY[
                          'pk', NEW.id::text,
                          'name', NEW.name,
                          'article', NEW.article,
                          'description', NEW.description,
                          'is_visible', is_visible,
                          'is_user_can_buy', is_user_can_buy,
                          'import_rate_to_rub', NEW.import_rate_to_rub::text,
                          'min_order', NEW.min_order::text,
                          'image', NEW.image,
                          'data_sheet', to_json(NEW.data_sheet)::text,
                          'attributes', to_json(NEW.attributes)::text,
                          'manufacturer', to_json(NEW.manufacturer)::text,
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
                          'product_card_id', NEW.product_card_id::text,
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

{% for key, supplier_products in supplier_product_model.items %}
/********* {{ supplier_products.model }} *********/
DROP TRIGGER IF EXISTS trigger_{{ supplier_products.model|lower }} ON {{ supplier_products.app }}_{{ supplier_products.model|lower }};

CREATE TRIGGER trigger_{{ supplier_products.model|lower }}
AFTER INSERT OR UPDATE OR DELETE ON {{ supplier_products.app }}_{{ supplier_products.model|lower }} FOR EACH ROW EXECUTE PROCEDURE sphinx_products ("{{ supplier_products.app }}_index");

{% endfor %}

/********* Catalog index *********/

CREATE OR REPLACE FUNCTION sphinx_catalog() RETURNS TRIGGER AS $$
DECLARE
    index_name varchar(254);
    is_hidden varchar(1);
    result text;
BEGIN
    index_name := 'catalog_index';
    RAISE NOTICE 'Calling sphinx_catalog(%)', index_name;

    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        /* Converted boolean to string (1/0) */
        is_hidden := (SELECT case when NEW.is_hidden=true then 1 else 0 end)::text;

        result := (SELECT sphinx_replace(index_name, NEW.id,
                          ARRAY[
                          'name', NEW.name,
                          'mptt_level', NEW.mptt_level::text,
                          'total_products', NEW.total_products::text,
                          'is_hidden', is_hidden
                          ]));

        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        result := sphinx_delete(index_name, OLD.id);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_catalog ON product_catalog;

CREATE TRIGGER trigger_catalog
AFTER INSERT OR UPDATE OR DELETE ON product_catalog FOR EACH ROW EXECUTE PROCEDURE sphinx_catalog ();

/********* Manufacturer index *********/

CREATE OR REPLACE FUNCTION sphinx_manufacturer() RETURNS TRIGGER AS $$
DECLARE
    index_name varchar(254);
    result text;
BEGIN
    index_name := 'manufacturer_index';
    RAISE NOTICE 'Calling sphinx_manufacturer(%)', index_name;

    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN

        result := (SELECT sphinx_replace(index_name, NEW.id,
                          ARRAY[
                          'name_manufacturer', NEW.name_manufacturer
                          ]));

        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        result := sphinx_delete(index_name, OLD.id);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_manufacturer ON manufacturer_manufacturer;

CREATE TRIGGER trigger_manufacturer
AFTER INSERT OR UPDATE OR DELETE ON manufacturer_manufacturer FOR EACH ROW EXECUTE PROCEDURE sphinx_manufacturer ();

/********* Product Card index *********/

CREATE OR REPLACE FUNCTION sphinx_product_card() RETURNS TRIGGER AS $$
DECLARE
    index_name varchar(254);
    result text;
BEGIN
    index_name := 'product_card_index';
    RAISE NOTICE 'Calling sphinx_product_card(%)', index_name;

    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN

        result := (SELECT sphinx_replace(index_name, NEW.id,
                          ARRAY[
                          'name', NEW.name,
                          'manufacturer', to_json(NEW.manufacturer)::text,
                          'manufacturer_text_list', to_json(NEW.manufacturer_text_list)::text,
                          'description', NEW.description,
                          'description_big', NEW.description_big,
                          'attributes', to_json(NEW.attributes)::text,
                          'catalog_id', NEW.catalog_id::text,
                          'slug', NEW.slug,
                          'slug_catalog', NEW.slug_catalog
                          ]));

        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        result := sphinx_delete(index_name, OLD.id);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_productcard ON product_card_productcard;

CREATE TRIGGER trigger_productcard
AFTER INSERT OR UPDATE OR DELETE ON product_card_productcard FOR EACH ROW EXECUTE PROCEDURE sphinx_product_card ();