-- Clement's Function


CREATE OR REPLACE FUNCTION setdomain(role VARCHAR(30))
  RETURNS TABLE(
    category_id INT,
    category_name VARCHAR(30),
    domain_id INT,
    domain_suffix VARCHAR(30)
  )AS
$$
DECLARE
  domainid INT;
  countduplicate INT;
BEGIN
  SELECT count(category_name) INTO countduplicate FROM category WHERE category_name = role;

  IF countduplicate = 0 THEN
    INSERT INTO domain(domain_suffix) VALUES (concat(role, '.pas.org'));
    SELECT domain.domain_id INTO domainid FROM domain WHERE domain.domain_suffix = concat(role, '.pas.org');
    INSERT INTO category(category_name, domain_id) VALUES (role, domainid);
  ELSE
    RAISE NOTICE 'Duplicate Entry';
  END IF;

  RETURN QUERY SELECT category.category_id, category.category_name, domain.domain_id, domain.domain_suffix
               FROM domain INNER JOIN category USING (domain_id);
END;
$$LANGUAGE plpgsql;