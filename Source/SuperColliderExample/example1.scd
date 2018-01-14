// example code for SuperCollider Playground
SynthDef(\sine, { |outbus = 0, amp = 0.5, freq = 440, pan = 0|
        var data;
        freq = Lag.kr(freq, 0.1);
        data = SinOsc.ar(freq, 0, amp);
        Out.ar(outbus, Pan2.ar(data, pan));
}).store;
