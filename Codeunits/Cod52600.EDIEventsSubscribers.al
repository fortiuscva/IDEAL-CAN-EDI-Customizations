codeunit 52600 "IDL EDI Events & Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Sales Order", OnAfterSalesLineModify, '', false, false)]
    local procedure Cod14002365_OnAfterSalesLineModify(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; EDIRecDocFields: Record "LAX EDI Receive Document Field");
    begin
        if SalesLine."LAX EDI Original Qty." <> SalesLine.Quantity then begin
            SalesLine."IDL EDI Qty Discr." := true;
            SalesLine.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", OnBeforeReleaseSalesDoc, '', false, false)]
    local procedure COD414_OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean; var SkipCheckReleaseRestrictions: Boolean; SkipWhseRequestOperations: Boolean);
    begin
        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            if EDIFunctionsGbl.EDIQtyDiscLinesExist(SalesHeader) then
                Error(EDIQtyPriceDiscExistsErrMsg);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnSendSalesDocForApproval, '', false, false)]
    local procedure Cod1535_OnSendSalesDocForApproval(var SalesHeader: Record "Sales Header");
    begin
        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            if EDIFunctionsGbl.EDIQtyDiscLinesExist(SalesHeader) then
                Error(EDIQtyPriceDiscExistsErrMsg);
        end;
    end;


    var
        EDIFunctionsGbl: Codeunit "IDL EDI Functions";
        EDIQtyPriceDiscExistsErrMsg: Label 'One or more line(s) have qty. discrepancy';




}
