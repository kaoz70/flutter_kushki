package com.flutterkushki.flutter_kushki.tasks;

import android.os.AsyncTask;

import com.kushkipagos.android.Card;
import com.kushkipagos.android.Kushki;
import com.kushkipagos.android.Transaction;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class GetToken extends AsyncTask<Card , Integer, Transaction> {
    private Exception exception;
    private Kushki kushki;
    private double amount;
    private MethodChannel.Result result;

    public GetToken(Kushki kushki, double amount, MethodChannel.Result result) {
        this.kushki = kushki;
        this.amount = amount;
        this.result = result;
    }

    @Override
    protected Transaction doInBackground(Card... card) {
        try {
            return kushki.requestToken(card[0], amount);
        } catch (Exception exception) {
            this.exception = exception;
            return null;
        }
    }

    protected void onPostExecute(Transaction transaction) {
        if (transaction == null) {
            result.error("error", exception.toString(), null);
        } else {
            if (!transaction.isSuccessful()) {
                result.error("error", transaction.getMessage(), null);
            } else {
                result.success(transaction.getToken());
            }
        }
    }
}