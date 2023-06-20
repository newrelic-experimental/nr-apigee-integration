const scriptStart = Date.now();  // Record the time taken to run this script

function parseW3CTraceId(traceId) {
    // Define the regular expression pattern for parsing the trace ID
    const pattern = /(\d{2})-([A-Za-z0-9]{32})-([A-Za-z0-9]{16})-(00|01)/;
    // Match the trace ID against the pattern
    const matches = traceId.match(pattern);
    if (matches) {
        // Extract components
        w3cVerNum = matches[1];
        w3cTraceId = matches[2];
        w3cParentId = matches[3];
        w3cTraceFlag = matches[4];
    }
    return { w3cVerNum: w3cVerNum, w3cTraceId: w3cTraceId, w3cParentId: w3cParentId, w3cTraceFlag: w3cTraceFlag };
}

// Generate a random Hex string of variable length
function randomHexString(len) {
    var hexString = "";
    for (var i = 0; i < len; i++) {
        hexString += (Math.floor(Math.random() * 16)).toString(16);
    }
    return hexString;
}

function generateValidId(len) {
    var id = randomHexString(len);
    // Ids must not be all zeros
    while (!(/[1-9a-f]/).test(id)) {
        id = randomHexString(len);
    }
    return id;
}

function isProbabalistic() {
    var isProbabalistic = false;
    if (properties.tracesSamplerArg) {
        isProbabalistic = Number(properties.tracesSamplerArg) >= Math.random();
    } else {
        print("Sampler traceidratio requires a tracesSamplerArg");
    }
    return isProbabalistic;
}

function getSampled(traceFlag) {
    /**
     * Tracer sampler configuration:
     *     - always_on - Sampler that always samples spans, regardless of the parent span’s sampling decision.
     *     - always_off - Sampler that never samples spans, regardless of the parent span’s sampling decision.
     *     - traceidratio - Sampler that samples probabalistically based on rate.
     *     - parentbased_always_on - (default) Sampler that respects its parent span’s sampling decision, but otherwise always samples.
     *     - parentbased_always_off - Sampler that respects its parent span’s sampling decision, but otherwise never samples.
     *     - parentbased_traceidratio - Sampler that respects its parent span’s sampling decision, but otherwise samples probabalistically based on rate.
     */
    var isSampled;
    var tracesSampler = String(properties.tracesSampler);  // properties are objects, and equality with strings doesn't work

    if (tracesSampler === SAMPLER_ALWAYS_ON) {
        isSampled = true;
    } else if (tracesSampler === SAMPLER_ALWAYS_OFF) {
        isSampled = false;
    } else if (tracesSampler === SAMPLER_TRACE_ID_RATIO) {
        isSampled = isProbabalistic(isSampled);
    } else if (tracesSampler === SAMPLER_PARENT_BASED_ALWAYS_ON) {
        if (traceFlag === W3C_TRACE_SAMPLED_FLAG) {
            isSampled = true;
        } else if (traceFlag === W3C_TRACE_NOT_SAMPLED_FLAG) {
            isSampled = false;
        } else {
            isSampled = true;
        }
    } else if (tracesSampler === SAMPLER_PARENT_BASED_ALWAYS_OFF) {
        if (traceFlag === W3C_TRACE_SAMPLED_FLAG) {
            isSampled = true;
        } else if (traceFlag === W3C_TRACE_NOT_SAMPLED_FLAG) {
            isSampled = false;
        } else {
            isSampled = false;
        }        
    } else if (tracesSampler === SAMPLER_PARENT_BASED_TRACE_ID_RATIO) {
        if (traceFlag === W3C_TRACE_SAMPLED_FLAG) {
            isSampled = true;
        } else if (traceFlag === W3C_TRACE_NOT_SAMPLED_FLAG) {
            isSampled = false;
        } else {
            isSampled = isProbabalistic();
        }
    }
    return isSampled;
};

const W3C_VER_NUM = "00";
const W3C_TRACE_NOT_SAMPLED_FLAG = "00";
const W3C_TRACE_SAMPLED_FLAG = "01";
const SAMPLER_ALWAYS_ON = "always_on";
const SAMPLER_ALWAYS_OFF = "always_off";
const SAMPLER_TRACE_ID_RATIO = "traceidratio";
const SAMPLER_PARENT_BASED_ALWAYS_ON = "parentbased_always_on";
const SAMPLER_PARENT_BASED_ALWAYS_OFF = "parentbased_always_off";
const SAMPLER_PARENT_BASED_TRACE_ID_RATIO = "parentbased_traceidratio";
var w3cVerNum;
var w3cTraceId;
var w3cParentId;
var w3cTraceFlag;

// Read W3C trace context
var w3cTraceparent = context.getVariable("request.header.traceparent");
var w3cTracestate = context.getVariable("request.header.tracestate");

// Decode traceparent
if (w3cTraceparent) {
    try {
        ({ w3cVerNum: w3cVerNum, w3cTraceId: w3cTraceId, w3cParentId: w3cParentId, w3cTraceFlag: w3cTraceFlag } = parseW3CTraceId(w3cTraceparent));  // ( .. ) around the assignment statement is required syntax when using object literal destructuring assignment without a declaration
    } catch (e) {
        print("Something went wrong in decoding Trace Parent.", w3cTraceparent);
    }
    print("W3C trace context included on inbound request");
} else {
    print("W3C trace context not included on inbound request");
}

// Determine if the trace is to be sampled
var traceSampled = getSampled(w3cTraceFlag);

if (traceSampled) {
    // Generate a spanID for apigee for the proxy
    var apigeeSpanId = generateValidId(16);

    // Creates a W3C traceId if there is no traceparent
    if (w3cTraceparent === null) {
        w3cTraceId = generateValidId(32);
    }

    // Set distributed trace specific context variables
    context.setVariable("dt.trace.id", w3cTraceId); // the trace id, same for all spans
    if (w3cParentId) {
        context.setVariable("dt.parent.id.fragment", ",\"parent.id\": \"" + w3cParentId + "\"");
        // context.setVariable("dt.parent.id.fragment", `,\"parent.id\": \"${w3cParentId}\"`);  // Template literals require Rhino Javascript 1.7.14
    } else {
        context.setVariable("dt.parent.id.fragment", "");
    }

    // Get timestamps from the apigee flow variables
    var targetStart = context.getVariable("target.sent.start.timestamp");
    var targetEnd = context.getVariable("target.received.end.timestamp");
    var apigeeStart = context.getVariable("client.received.start.timestamp");

    if (targetStart) {  // The backend target was called
        // Generate a spanID for apigee for the target
        var targetSpanId = generateValidId(16);
        context.setVariable("dt.target.span.fragment",
            ', ' +
            '{ ' +
                '"trace.id": \"' + w3cTraceId + '\", ' +
                '"id": \"' + targetSpanId + '\", ' +
                '"attributes": { ' +
                '    "duration.ms": ' + (targetEnd - targetStart) + ', ' +
                '    "target.sent.start.timestamp": ' + targetStart + ', ' +
                '    "target.received.end.timestamp": ' + targetEnd + ', ' +
                '    "name": \"' + context.getVariable("target.url") + '\", ' +
                '    "parent.id": \"' + apigeeSpanId + '\", ' +
                '    "response.code": ' + context.getVariable("message.status.code") +
                '}, ' +
                '"timestamp": ' + targetStart +
            '}'
        );
    } else {  // The backend target was not called
        print("A target was not called, e.g. due to a cache hit");
        context.setVariable("dt.target.span.fragment", "");
    }
    context.setVariable("dt.apigee.span.id", apigeeSpanId); // a span id to cover the whole apigee flow
    context.setVariable("dt.target.span.id", targetSpanId); // a span id to just cover the target request
    context.setVariable("dt.sampled", traceSampled); // indicates that proxy is sampled

    // TODO: Process any internal spans so they can be added to the trace payload

    // Set the traceparent and tracestate for the backend service 
    context.setVariable("request.header.traceparent", W3C_VER_NUM + "-" + w3cTraceId + "-" + targetSpanId + "-" + traceSampled ? W3C_TRACE_SAMPLED_FLAG : W3C_TRACE_NOT_SAMPLED_FLAG);
    // Preserve tracestate
    //context.setVariable("request.header.tracestate", "");

    // Set the target duration and approximate apigee duration (client.sent.end.timestamp is only known in the PostClientFlow)
    context.setVariable("dt.target.duration", targetEnd - targetStart);
    context.setVariable("dt.apigee.approx.duration", Date.now() - apigeeStart);
}

context.setVariable("dt.nr.latency", Date.now() - scriptStart);  // Record the time taken to run this script