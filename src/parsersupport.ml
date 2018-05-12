open Core

module IdentSet = Set.Make(String)

let typeIdents = ref IdentSet.empty

let addTypeIdent (x: string): unit = begin
    (* ignore (printf "New type identifier %s\n" x); *)
    typeIdents := IdentSet.add !typeIdents x
end

let isTypeIdent (x: string): bool = IdentSet.mem !typeIdents x
