codeunit 52600 "IDL EDI Events & Subscribers"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Load Fields", OnAfterSetUpOutFields, '', false, false)]
    local procedure OnAfterSetUpOutFields();
    var
        LAXEDILoadFields: Codeunit "LAX EDI Load Fields";
        LAXFieldType: Enum "LAX EDI Virtual Field Type";
        LAXDataType: Enum "LAX EDI ERP Data Type";
    begin
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'SAC Amount', LAXDataType::Decimal, 'SAC Amount (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'SAC *01', LAXDataType::Text, 'SAC *01 (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'TDS*04', LAXDataType::Decimal, 'TDS*04 (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'Tax %', LAXDataType::Decimal, 'Tax % (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'Bill of Lading No.', LAXDataType::Text, 'Bill of Lading No. (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'EDI Discount Code', LAXDataType::Text, 'EDI Discount Code (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'EDI Description', LAXDataType::Text, 'EDI Description (IDL)');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Sales Invoice Send", OnBeforeLoadEDIOut, '', false, false)]
    local procedure cod14002360_OnBeforeLoadEDIOut(EDIElement: Record "LAX EDI Element"; SalesInvoiceHeader: Record "Sales Invoice Header"; SalesInvoiceLine: Record "Sales Invoice Line"; var CustomEDIOut: Boolean; var BoolenVariable: Boolean; var DateVariable: Date; var IntegerVariable: Integer; var DecimalVariable: Decimal; var TimeVariable: Time; var DateTimeVariable: DateTime; i: Integer; var OutFldArray: array[100] of Text);
    var
        SalesInvoiceLineRecLcl: Record "Sales Invoice Line";
        BOLFoundVarLcl: Boolean;
        TempSalesShptLine: Record "Sales Shipment Line" temporary;
        LAXBillofLadingLineRecLcl: Record "LAX Bill of Lading Line";
    begin
        case EDIElement."Field Name" of
            'SAC Amount':
                begin
                    OutFldArray[i] := '';
                    DecimalVariable := EDISingleInstance.GetSACAmount();
                    CustomEDIOut := true;
                end;
            'SAC *01':
                begin
                    OutFldArray[i] := '';
                    OutFldArray[i] := EDISingleInstance.GetSAC01();
                    CustomEDIOut := true;
                end;
            'TDS*04':
                begin
                    OutFldArray[i] := '';
                    PaymentTermsRecGbl.reset;
                    if SalesInvoiceHeader."Payment Discount %" <> 0 then begin
                        SalesInvoiceHeader.CalcFields("Amount Including VAT");
                        DecimalVariable := SalesInvoiceHeader."Amount Including VAT" / SalesInvoiceHeader."Payment Discount %";
                    end;
                    CustomEDIOut := true;
                end;
            'Tax %':
                begin
                    OutFldArray[i] := '';
                    SalesInvoiceLineRecLcl.Reset();
                    SalesInvoiceLineRecLcl.SetRange("Document No.", SalesInvoiceHeader."No.");
                    SalesInvoiceLineRecLcl.SetFilter("VAT %", '<>%1', 0);
                    if SalesInvoiceLineRecLcl.FindFirst() then
                        DecimalVariable := SalesInvoiceLineRecLcl."VAT %";
                    CustomEDIOut := true;
                end;
            'Bill of Lading No.':
                begin
                    OutFldArray[i] := '';
                    BOLFoundVarLcl := false;
                    SalesInvoiceLineRecLcl.Reset();
                    SalesInvoiceLineRecLcl.SetRange("Document No.", SalesInvoiceHeader."No.");
                    SalesInvoiceLineRecLcl.SetRange(Type, SalesInvoiceLineRecLcl.Type::Item);
                    SalesInvoiceLineRecLcl.SetFilter(Quantity, '<>%1', 0);
                    if SalesInvoiceLineRecLcl.FindSet() then begin
                        repeat
                            TempSalesShptLine.Reset();
                            TempSalesShptLine.DeleteAll();
                            SalesInvoiceLineRecLcl.GetSalesShptLines(TempSalesShptLine);
                            if TempSalesShptLine.FindFirst() then begin
                                LAXBillofLadingLineRecLcl.Reset();
                                LAXBillofLadingLineRecLcl.SetRange(Type, LAXBillofLadingLineRecLcl.Type::"Sales Shipment (Posted)");
                                LAXBillofLadingLineRecLcl.SetRange("No.", TempSalesShptLine."Document No.");
                                if LAXBillofLadingLineRecLcl.FindFirst() then begin
                                    OutFldArray[i] := LAXBillofLadingLineRecLcl."Bill of Lading No.";
                                    BOLFoundVarLcl := true;
                                end;
                            end;
                        until (SalesInvoiceLineRecLcl.Next() = 0) OR BOLFoundVarLcl;
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Sales Order", OnBeforeUpdateReceiveDocStatusFields, '', false, false)]
    local procedure cod14002365_OnBeforeUpdateReceiveDocStatusFields(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.");
    Var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Reset;
        SalesHeader.SetCurrentKey("LAX EDI Order", "LAX EDI Trade Partner", "LAX EDI Internal Doc. No.");
        SalesHeader.SetRange("LAX EDI Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        if SalesHeader.Find('-') then
            repeat
                SalesHeader.Calcbottomline(SalesHeader)
            until SalesHeader.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Sales Invoice Send", OnBeforeReadAssocTables, '', false, false)]
    local procedure cod14002360_OnBeforeReadAssocTables(SalesInvoiceHeader: Record "Sales Invoice Header");
    begin
        EDISingleInstance.BuildBLDSalesInvoiceLines(SalesInvoiceHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Sales Invoice Send", OnBeforeNextEDISegment, '', false, false)]
    local procedure cod14002360_OnBeforeNextEDISegment(var EDISegment: Record "LAX EDI Segment"; LoopFinished: Boolean);
    begin
        If EDISegment.Segment = 'SAC-DISC' then begin
            if not EDISingleInstance.GetNextBLDSalesInvoiceLine() then
                LoopFinished := true
            else begin
                EDISegment.Next(-1);
                LoopFinished := false;
            end;
        end;
    end;


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
        LAXEDICreateSalesOrder: Codeunit "LAX EDI Create Sales Order";
        EDISingleInstance: Codeunit "IDL EDI Single Instance";

        PaymentTermsRecGbl: Record "Payment Terms";




}
