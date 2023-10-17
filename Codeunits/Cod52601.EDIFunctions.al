codeunit 52601 "IDL EDI Functions"
{
    procedure EDIQtyDiscLinesExist(SalesHeaderPar: Record "Sales Header"): Boolean
    var
        SalesLineRecLcl: Record "Sales Line";
    begin
        SalesLineRecLcl.Reset();
        SalesLineRecLcl.SetRange("Document Type", SalesHeaderPar."Document Type");
        SalesLineRecLcl.SetRange("Document No.", SalesHeaderPar."No.");
        SalesLineRecLcl.SetRange("IDL EDI Qty Discr.", true);
        exit(SalesLineRecLcl.FindFirst());
    end;


}
