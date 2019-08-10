CREATE TABLE paths (
  id INT NOT NULL AUTO_INCREMENT,
  keyword VARCHAR(32),
  path VARCHAR(512) NOT NULL,
  size DOUBLE NOT NULL,
  type VARCHAR(32) NOT NULL,
  created DATETIME,
  modified DATETIME,
  scanned DATE,
  PRIMARY KEY (id ASC),
  UNIQUE (path, scanned)
) DEFAULT CHARSET = utf8 ENGINE = InnoDB;
