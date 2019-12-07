plot(time.erode, 'k.')
hold on
plot(time.stable, 'g.')
plot(time.notch1, 'b')
plot(time.rotblock, 'r')
plot(time.erodeblock, 'y')
plot(time.puttogether,'c')
plot(time.corners,'k')
plot(time.blockstable, 'g')
plot(time.blockrotate, 'r.')

legend('erode','stable','notch1', 'rotblock','erodeblock','puttogether', 'corners','blockstable','blockrotate')