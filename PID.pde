
void control() {
  currentErrX = referencePosX - currentX;
  currentErrY = referencePosY - currentY;
  ErrorSumX += currentErrX * sampleTime / 1000.0;
  ErrorSumY += currentErrY * sampleTime / 1000.0;
  ErrorSumX = constrain(ErrorSumX, -500, 500);
  ErrorSumY = constrain(ErrorSumY, -500, 500);
  float ErrorDiffX = (currentErrX - lastErrX) * 1000.0 / (sampleTime);
  float ErrorDiffY = (currentErrY - lastErrY) * 1000.0 / (sampleTime);
  lastErrX = currentErrX;
  lastErrY = currentErrY;
  outputX = Kpx * currentErrX + Kdx * ErrorDiffX + Kix * ErrorSumX;
  outputY = Kpy * currentErrY + Kdy * ErrorDiffY + Kiy * ErrorSumY;
  finX = outputX;
  finY = outputY;
  if (outputX < 0)
    finX = constrain(90 - abs(outputX), 5, 90);
  else
    finX = constrain(90 + outputX, 90, 175);
  if  (outputY < 0)
    finY = constrain(90 - abs(outputY), 5, 90);
  else
    finY = constrain(90 + outputY, 90, 175);
  if ( currentX <= referencePosX+5 && currentX >= referencePosX-5) {
    finX = 105;
    ErrorSumX = 0;
  }
  if (currentY <= referencePosY+5 && currentY >= referencePosY-5) {
    finY = 80;
    ErrorSumX = 0 ;
  }
}