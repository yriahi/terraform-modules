
variable "region" {
  type = "string"
  description = "The AWS region to scope access to (defaults to current region)."
  default = ""
}
variable "account_id" {
  type = "string"
  description = "The AWS account ID to scope access to (defaults to current account)."
  default = ""

}
variable "key_alias" {
  type = "string"
  description = "The KMS key alias that is used for Chamber parameters."
  default = "alias/parameter_store_key"
}
variable "namespace" {
  type = "string"
  description = "The Chamber namespace to create policies for."
}