CREATE TABLE dogs (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO
  houses (id, address)
VALUES
  (1, "19th and Taraval"), (2, "3rd and Market");

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, "Michael", "Jordan", 1),
  (2, "Charles", "Barkely", 1),
  (3, "Tim", "Duncan", 2),
  (4, "Lebron", "James", NULL);

INSERT INTO
  dogs (id, name, owner_id)
VALUES
  (1, "Fido", 1),
  (2, "Scoobie", 2),
  (3, "Porkchop", 3),
  (4, "Santa's Little Helper", 3),
  (5, "Null dog", NULL);
