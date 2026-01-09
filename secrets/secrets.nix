let
  tom = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdnwVGpMaBv5Bx2XuIvuBI+b4HNaPYcuPoGSzZi/Z5R ffrn@tom v1"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMERALdLOOYZP5ENpa+VXzYSM7ABn9POZL6hJDoxt4s tom@zeus"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl4GaQ0liA4sCgQeabUzYiZbvr5VqqSmSxaL4YpZapc tom@tom-laptop2"
  ];

  admins = tom;

  gluon-census = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE9m7razm+ViAPWCe638vXa9PdJlBWQNk5TVcj9He/n2 root@gluon-census" ];
  systems = [ gluon-census ];
in
{
  "grafana-github-client-secret.age" = {
    publicKeys = admins ++ gluon-census;
    #armor = true;
  };
}
