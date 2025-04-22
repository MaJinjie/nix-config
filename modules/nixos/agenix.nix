{ secrets, user, ... }: 

{
  age.identityPaths = [
    "/home/${user}/.ssh/id_ed25519"
  ];
  age.secrets = {
    "login-passwd" = {
      file = "${secrets}/login-passwd.age";
      mode = "600";
      owner = "${user}";
      group = "users";
    };
  };
}
