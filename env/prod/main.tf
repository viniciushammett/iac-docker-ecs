module "prod" {
    source = "../../infra"

    nome_repositorio = "producao"
    cargoiam = "producao"
}

output "IP_alb" {
  value = module.prod.IP
}