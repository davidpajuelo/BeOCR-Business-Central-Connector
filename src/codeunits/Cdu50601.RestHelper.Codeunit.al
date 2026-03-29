codeunit 50601 "API Rest Helper"
{
    Access = Public;

    var
        ContentTypeSet: Boolean;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
        HttpRequestMessageHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        CurrentContentType: Text;
        RestHeaders: TextBuilder;

    procedure Initialize(Method: Text; URI: Text);
    begin
        HttpRequestMessage.Method := Method;
        HttpRequestMessage.SetRequestUri(URI);

        HttpRequestMessage.GetHeaders(HttpRequestMessageHeaders);
    end;

    procedure AddDefaultRequestHeaders()
    begin
        HttpRequestMessageHeaders := HttpClient.DefaultRequestHeaders();
    end;

    procedure AddRequestHeader(HeaderKey: Text; HeaderValue: Text)
    begin
        RestHeaders.AppendLine(HeaderKey + ': ' + HeaderValue);

        HttpRequestMessageHeaders.Add(HeaderKey, HeaderValue);
    end;

    procedure AddBody(Body: Text)
    begin
        HttpContent.WriteFrom(Body);

        ContentTypeSet := true;
    end;

    procedure SetContentType(ContentType: Text)
    begin
        CurrentContentType := ContentType;

        HttpContent.GetHeaders(HttpContentHeaders);
        if HttpContentHeaders.Contains('Content-Type') then
            HttpContentHeaders.Remove('Content-Type');
        HttpContentHeaders.Add('Content-Type', ContentType);
    end;

    procedure Send(Body: text) SendSuccess: Boolean
    var
        StartDateTime: DateTime;
        TotalDuration: Duration;
    begin
        if ContentTypeSet then
            HttpRequestMessage.Content(HttpContent);
        OnBeforeSend(HttpRequestMessage, HttpResponseMessage);
        StartDateTime := CurrentDateTime();
        SendSuccess := HttpClient.send(HttpRequestMessage, HttpResponseMessage);
        TotalDuration := CurrentDateTime() - StartDateTime;
        OnAfterSend(HttpRequestMessage, HttpResponseMessage);

        if SendSuccess then
            if not HttpResponseMessage.IsSuccessStatusCode() then
                SendSuccess := false;

        InsertLog(StartDateTime, TotalDuration);
    end;

    procedure GetResponseContentAsText() ResponseContentText: Text
    var
        TempBlob: Codeunit "Temp Blob";
        Instream: Instream;
    begin

        TempBlob.CreateInStream(Instream);
        HttpResponseMessage.Content().ReadAs(ResponseContentText);
    end;

    procedure GetResponseReasonPhrase(): Text
    begin
        exit(HttpResponseMessage.ReasonPhrase());
    end;

    procedure GetHttpStatusCode(): Integer
    begin
        exit(HttpResponseMessage.HttpStatusCode());
    end;

    local procedure InsertLog(StartDateTime: DateTime; TotalDuration: Duration)
    var
        //BTRestLog: Record "RA Rest Log";
        TempBlobResponse: Codeunit "Temp Blob";
        TempBlobRest: Codeunit "Temp Blob";
        InStream: InStream;
        ResponseInStream: InStream;
        OutStream: OutStream;
    begin
        TempBlobRest.CreateInStream(InStream);
        HttpContent.ReadAs(InStream);

        TempBlobResponse.CreateInStream(ResponseInStream);
        HttpResponseMessage.Content().ReadAs(ResponseInStream);

    end;



    [IntegrationEvent(true, false)]
    local procedure OnBeforeSend(HttpRequestMessage: HttpRequestMessage; HttpResponseMessage: HttpResponseMessage)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterSend(HttpRequestMessage: HttpRequestMessage; HttpResponseMessage: HttpResponseMessage)
    begin
    end;


}