codeunit 52602 "IDL EDI Single Instance"
{
    SingleInstance = true;



    procedure BuildBLDSalesInvoiceLines(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        TempBLDSalesInvoiceLine.Reset();
        TempBLDSalesInvoiceLine.DeleteAll();

        OrigSalesInvoiceLine.Reset();
        OrigSalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        OrigSalesInvoiceLine.SetFilter("No.", '<>%1', '');
        OrigSalesInvoiceLine.SetRange(BLD, TRUE);
        if OrigSalesInvoiceLine.Find('-') then
            repeat
                if OrigSalesInvoiceLine."IDL Combine EDI Codes" then begin
                    TempBLDSalesInvoiceLine.Reset();
                    TempBLDSalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                    //TempBLDSalesInvoiceLine.SETRANGE("No.",OrigSalesInvoiceLine."No.");
                    TempBLDSalesInvoiceLine.SetRange("IDL EDI Discount Code", OrigSalesInvoiceLine."IDL EDI Discount Code");
                    IF TempBLDSalesInvoiceLine.FindFirst() then begin
                        TempBLDSalesInvoiceLine."Line Amount" += OrigSalesInvoiceLine."Line Amount";
                        TempBLDSalesInvoiceLine.Modify();
                    end else begin
                        TempBLDSalesInvoiceLine.Init();
                        TempBLDSalesInvoiceLine.Copy(OrigSalesInvoiceLine);
                        TempBLDSalesInvoiceLine.Insert();
                    end;
                end else begin
                    TempBLDSalesInvoiceLine.Init();
                    TempBLDSalesInvoiceLine.Copy(OrigSalesInvoiceLine);
                    TempBLDSalesInvoiceLine.Insert();
                end;
            until OrigSalesInvoiceLine.Next() = 0;
        if TempBLDSalesInvoiceLine.FindFirst() then;
    end;

    procedure GetNextBLDSalesInvoiceLine(): Boolean
    begin
        if TempBLDSalesInvoiceLine.Next() = 0 then
            exit(false);

        exit(true);
    end;

    procedure BuildTaxAmountLines(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        clear(TempSalesTaxAmtLine);
        TempSalesTaxAmtLine.DeleteAll();

        if SalesInvoiceHeader."Tax Area Code" <> '' then begin
            TaxArea.Get(SalesInvoiceHeader."Tax Area Code");
        end;

        SalesTaxCalc.StartSalesTaxCalculation();
        if TaxArea."Use External Tax Engine" then
            SalesTaxCalc.CallExternalTaxEngineForDoc(DATABASE::"Sales Invoice Header", 0, SalesInvoiceHeader."No.")
        else begin
            SalesTaxCalc.AddSalesInvoiceLines(SalesInvoiceHeader."No.");
            SalesTaxCalc.EndSalesTaxCalculation(SalesInvoiceHeader."Posting Date");
        end;
        SalesTaxCalc.GetSalesTaxAmountLineTable(TempSalesTaxAmtLine);
        //SalesTaxCalc.GetSummarizedSalesTaxTable(TempSalesTaxAmtLine);
        TempSalesTaxAmtLine.SetFilter("Tax %", '<>%1', 0);
        if TempSalesTaxAmtLine.FindFirst() then;
    end;

    procedure GetNextTaxAmountLine(): Boolean
    begin
        if TempSalesTaxAmtLine.Next() = 0 then
            exit(false);

        exit(true);
    end;


    procedure GetSACAmount(): Decimal;
    var
        SACAmountLcl: Decimal;
    begin
        Clear(SACAmountLcl);
        if TempBLDSalesInvoiceLine."Line Amount" < 0 then
            SACAmountLcl := (TempBLDSalesInvoiceLine."Line Amount" * -1)
        else
            SACAmountLcl := TempBLDSalesInvoiceLine."Line Amount";

        exit(SACAmountLcl);
    end;

    procedure GetSAC01(): Code[1];
    var
        SAC01Lcl: Code[1];
    begin
        Clear(SAC01Lcl);
        if TempBLDSalesInvoiceLine."Line Amount" > 0 then
            SAC01Lcl := 'C'
        else
            SAC01Lcl := 'A';

        exit(SAC01Lcl);
    end;

    procedure GetEDIDiscountCode(): Code[4];
    var
        EDIDiscountCodeLcl: Code[4];
    begin
        Clear(EDIDiscountCodeLcl);
        EDIDiscountCodeLcl := TempBLDSalesInvoiceLine."IDL EDI Discount Code";
        exit(EDIDiscountCodeLcl);
    end;

    procedure GetEDIDescription(): Text[50];
    var
        EDIDescriptionLcl: Code[50];
    begin
        Clear(EDIDescriptionLcl);
        EDIDescriptionLcl := TempBLDSalesInvoiceLine."IDL EDI Description";
        exit(EDIDescriptionLcl);
    end;

    procedure GetTaxPercent(): Decimal;
    var
        TaxPercentLcl: Decimal;
    begin
        Clear(TaxPercentLcl);
        TaxPercentLcl := TempSalesTaxAmtLine."Tax %";
        exit(TaxPercentLcl);
    end;


    var
        OrigSalesInvoiceLine: Record "Sales Invoice Line";
        TempBLDSalesInvoiceLine: Record "Sales Invoice Line" temporary;
        BottomLineDiscRecGbl: Record "Bottom Line Discount";
        SalesTaxCalc: Codeunit "Sales Tax Calculate";
        TaxArea: Record "Tax Area";
        TempSalesTaxAmtLine: Record "Sales Tax Amount Line" temporary;

}
